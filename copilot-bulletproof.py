import sys
import json
import subprocess
import threading
import time

user_code = None
ready_for_login = False
msg_id_counter = 1
lock = threading.Lock()

def read_messages(proc):
    global user_code, ready_for_login
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
            
            # Print everything
            print("<-", json.dumps(msg), flush=True)

            if "id" in msg and msg.get("result", {}).get("status") == "PromptUserDeviceFlow":
                user_code = msg["result"]["userCode"]
                print("\n\n*** GITHUB CODE: " + user_code + " ***\n\n", flush=True)
            
            if "method" in msg and "didChangeStatus" in msg["method"]:
                params = msg.get("params", {})
                if "statuses" in params:
                    for status in params["statuses"]:
                        if status.get("category") == "auth" and status.get("result", {}).get("status") == "NotSignedIn":
                            ready_for_login = True
                elif params.get("kind") == "Error" and "not signed into GitHub" in params.get("message", ""):
                    ready_for_login = True
            
            if "id" in msg and msg.get("result", {}).get("status") == "AlreadySignedIn":
                print("\n\n*** ALREADY SIGNED IN! ***\n\n", flush=True)

server_cmd = ["/opt/homebrew/bin/node", "/Users/goose/.config/emacs/.local/cache/copilot/bin/copilot-language-server", "--stdio"]
proc = subprocess.Popen(server_cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=sys.stderr)

t = threading.Thread(target=read_messages, args=(proc,), daemon=True)
t.start()

def send(method, params, is_notification=False):
    global msg_id_counter
    msg = {"jsonrpc": "2.0", "method": method, "params": params}
    if not is_notification:
        with lock:
            msg_id = msg_id_counter
            msg_id_counter += 1
        msg["id"] = msg_id
    payload = json.dumps(msg).encode('utf-8')
    header = f"Content-Length: {len(payload)}\r\n\r\n".encode('ascii')
    proc.stdin.write(header + payload)
    proc.stdin.flush()
    print("->", json.dumps(msg), flush=True)
    return msg.get("id")

send("initialize", {
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
time.sleep(1)
send("initialized", {}, is_notification=True)
send("workspace/didChangeConfiguration", {"settings": {}}, is_notification=True)

print("Waiting for server to become ready...", flush=True)
wait_start = time.time()
while not ready_for_login and time.time() - wait_start < 10:
    time.sleep(0.5)

print("Sending signInInitiate...", flush=True)
send("signInInitiate", {})

# Wait for user_code
wait_code_start = time.time()
while not user_code and time.time() - wait_code_start < 10:
    time.sleep(0.5)

if user_code:
    print("Waiting for you to authorize...", flush=True)
    send("signInConfirm", {"userCode": user_code})

time.sleep(600)
