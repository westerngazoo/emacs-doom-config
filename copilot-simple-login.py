import sys
import json
import subprocess
import threading
import time

user_code = None

def read_messages(proc):
    global user_code
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
            if "id" in msg and msg.get("result", {}).get("status") == "PromptUserDeviceFlow":
                user_code = msg["result"]["userCode"]
                print("\n\n*** CODE: " + user_code + " ***\n\n", flush=True)

server_cmd = ["/opt/homebrew/bin/node", "/Users/goose/.config/emacs/.local/cache/copilot/bin/copilot-language-server", "--stdio"]
proc = subprocess.Popen(server_cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=sys.stderr)

t = threading.Thread(target=read_messages, args=(proc,), daemon=True)
t.start()

def send(method, params, msg_id=None):
    msg = {"jsonrpc": "2.0", "method": method, "params": params}
    if msg_id is not None:
        msg["id"] = msg_id
    payload = json.dumps(msg).encode('utf-8')
    header = f"Content-Length: {len(payload)}\r\n\r\n".encode('ascii')
    proc.stdin.write(header + payload)
    proc.stdin.flush()

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
}, 1)
time.sleep(1)
send("initialized", {})
send("workspace/didChangeConfiguration", {"settings": {}})

time.sleep(3)
send("signInInitiate", {}, 2)

time.sleep(2)
if user_code:
    send("signInConfirm", {"userCode": user_code}, 3)

time.sleep(600)
