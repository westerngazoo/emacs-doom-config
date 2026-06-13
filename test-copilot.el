;; Test copilot setup - run with: emacs -Q --load ~/.config/doom/test-copilot.el
;; Or from within Emacs: M-x eval-buffer

(require 'copilot)

(message "========== COPILOT DEBUG ==========")
(message "copilot-install-dir: %s" copilot-install-dir)
(message "install-dir exists: %s" (file-directory-p copilot-install-dir))

(condition-case err
    (progn
      (message "server-executable: %s" (copilot-server-executable))
      (message "server exists: %s" (file-exists-p (copilot-server-executable))))
  (error (message "SERVER FIND ERROR: %S" err)))

(message "")
(message "Attempting to start server...")
(condition-case err
    (progn
      (copilot--start-server)
      (message "Server started: %s" (copilot--connection-alivep))
      (message "")
      (message "Checking auth status...")
      (let ((status (jsonrpc-request copilot--connection 'checkStatus (make-hash-table) :timeout 10)))
        (message "Auth status result: %S" status))
      (copilot--shutdown-server))
  (error (message "ERROR: %S" err))
  (user-error (message "USER-ERROR: %S" err)))

(message "========== END DEBUG ==========")
