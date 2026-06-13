import sys
import json
import subprocess
import threading
import time

msg_id_counter = 1
responses = {}
lock = threading.Lock()
ready_for_login = False

def read_messages(proc):
    global ready_for_login
    while True:
        line = proc.stdout.readline()
        if not line:
            break
        line = line.strip()
        if line.startswith(b"Content-Length: "):
            length = int(line.split(b": ")[1])
            proc.stdout.readline() # empty line
            content = proc.stdout.read(length)
            msg = json.loads(content)
            if "id" in msg and ("result" in msg or "error" in msg):
                with lock:
                    responses[msg["id"]] = msg
            if "method" in msg and "didChangeStatus" in msg["method"]:
                params = msg.get("params", {})
                if "statuses" in params:
                    for status in params["statuses"]:
                        if status.get("category") == "auth" and status.get("result", {}).get("status") == "NotSignedIn":
                            ready_for_login = True
                elif params.get("kind") == "Error" and "not signed into GitHub" in params.get("message", ""):
                    ready_for_login = True

server_cmd = ["/opt/homebrew/bin/node", "/Users/goose/.config/emacs/.local/cache/copilot/bin/copilot-language-server", "--stdio"]
proc = subprocess.Popen(server_cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=sys.stderr)

t = threading.Thread(target=read_messages, args=(proc,), daemon=True)
t.start()

def send(method, params):
    global msg_id_counter
    with lock:
        msg_id = msg_id_counter
        msg_id_counter += 1
    msg = {"jsonrpc": "2.0", "method": method, "params": params, "id": msg_id}
    payload = json.dumps(msg).encode('utf-8')
    header = f"Content-Length: {len(payload)}\r\n\r\n".encode('ascii')
    proc.stdin.write(header + payload)
    proc.stdin.flush()
    return msg_id

def wait_for_response(msg_id, timeout=600):
    start = time.time()
    while time.time() - start < timeout:
        with lock:
            if msg_id in responses:
                return responses[msg_id]
        time.sleep(0.5)
    return None

init_id = send("initialize", {
    "processId": 1,
    "capabilities": {
        "workspace": {"workspaceFolders": True},
        "textDocument": {"inlineCompletion": {"dynamicRegistration": False}}
    },
    "initializationOptions": {
        "editorInfo": {"name": "Emacs", "version": "29.4"},
        "editorPluginInfo": {"name": "copilot.el", "version": "0.4.0"}
    }
})
wait_for_response(init_id)
send("initialized", {})
send("workspace/didChangeConfiguration", {"settings": {}})

# Wait until the server is ready to login
wait_start = time.time()
while not ready_for_login and time.time() - wait_start < 10:
    time.sleep(0.5)

print("Requesting login code...", flush=True)
initiate_id = send("signInInitiate", {})
res = wait_for_response(initiate_id)

if "result" in res and res["result"].get("status") == "PromptUserDeviceFlow":
    userCode = res["result"]["userCode"]
    print(f"\n\n*** USER CODE: {userCode} ***\n\n", flush=True)
    
    print(f"Sending confirm request for {userCode} and waiting...", flush=True)
    confirm_id = send("signInConfirm", {"userCode": userCode})
    res_confirm = wait_for_response(confirm_id, timeout=300)
    print(f"signInConfirm result: {res_confirm}", flush=True)
    
    status_id = send("checkStatus", {})
    status_res = wait_for_response(status_id)
    print(f"Final status: {status_res}", flush=True)
else:
    print(f"Already signed in or failed to initiate: {res}", flush=True)
