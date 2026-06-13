#!/bin/bash
EMACS="/opt/homebrew/opt/emacs-mac@29/bin/emacs"
$EMACS --batch \
  --eval "(setq user-emacs-directory \"/Users/goose/.config/emacs/\")" \
  -l "/Users/goose/.config/emacs/early-init.el" \
  --eval "(progn
    (load (expand-file-name \"lisp/doom\" user-emacs-directory))
    (load (expand-file-name \"lisp/doom-start\" user-emacs-directory))
    (doom-initialize)
    (doom-initialize-packages)
    (require 'copilot)
    (setq copilot-install-dir (expand-file-name \"copilot\" doom-cache-dir))
    (princ (format \"[1] copilot-install-dir: %s\n\" copilot-install-dir))
    (condition-case err
      (progn
        (princ (format \"[2] server exe: %s\n\" (copilot-server-executable)))
        (princ (format \"[3] Starting server...\n\"))
        (copilot--start-server)
        (sleep-for 1)
        (princ (format \"[4] Server alive: %s\n\" (copilot--connection-alivep)))
        (let ((status (jsonrpc-request copilot--connection 'checkStatus (make-hash-table) :timeout 10)))
          (princ (format \"[5] AUTH STATUS: %S\n\" status)))
        (copilot--shutdown-server))
      (error (princ (format \"[ERROR] %S\n\" err)))
      (user-error (princ (format \"[USER-ERROR] %S\n\" err))))
    (kill-emacs 0))" 2>&1
