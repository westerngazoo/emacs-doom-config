;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; ── Identity ────────────────────────────────────────────────────────────────
(setq user-full-name  "Gustavo Delgadillo"
      user-mail-address "gustavo.delgadillo@gmail.com")

;; ── Platform detection ──────────────────────────────────────────────────────
(defvar my/macp   (eq system-type 'darwin))
(defvar my/linuxp (eq system-type 'gnu/linux))
(defvar my/wslp   (and my/linuxp
                       (file-exists-p "/proc/sys/fs/binfmt_misc/WSLInterop")))

(when my/macp
  (setenv "PATH" (concat "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:" (getenv "PATH")))
  (add-to-list 'exec-path "/opt/homebrew/bin")
  (add-to-list 'exec-path "/opt/homebrew/sbin")
  (add-to-list 'exec-path "/usr/local/bin"))

;; ── Font ────────────────────────────────────────────────────────────────────
(setq doom-font (font-spec
                 :family (if my/macp "JetBrainsMono Nerd Font"
                           "JetBrainsMono Nerd Font Mono")
                 :size (if my/macp 15 14))
      doom-variable-pitch-font (font-spec :family "JetBrainsMono Nerd Font" :size 13)
      doom-big-font (font-spec :family "JetBrainsMono Nerd Font" :size 20))

;; ── Theme ────────────────────────────────────────────────────────────────────
(setq doom-theme 'doom-acario-dark)

;; ── Line numbers ─────────────────────────────────────────────────────────────
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

;; ── vterm — right side panel ─────────────────────────────────────────────────
(after! vterm
  (setq vterm-shell (or (executable-find "zsh") shell-file-name)))

;; Override Doom's bottom popup after all modules load
(add-hook! 'doom-after-init-hook
  (set-popup-rule! "^\\*vterm" :side 'right :width 0.38 :select t :quit nil :ttl 0))

;; ── Editor feel ──────────────────────────────────────────────────────────────
(setq-default
 scroll-margin          8
 tab-width              2
 fill-column            100
 truncate-lines         t)

(setq evil-split-window-below  t
      evil-vsplit-window-right t)

;; ── Treemacs on the right (like your neo-tree setup) ────────────────────────
(after! treemacs
  (setq treemacs-position            'right
        treemacs-width               35
        treemacs-show-hidden-files   t
        treemacs-git-mode            'extended))

(map! :leader
      :desc "File tree"            "e"  #'+treemacs/toggle)

;; ── Modeline ─────────────────────────────────────────────────────────────────
(after! doom-modeline
  (setq doom-modeline-height          35
        doom-modeline-bar-width        4
        doom-modeline-icon             t
        doom-modeline-major-mode-icon  t
        doom-modeline-buffer-encoding  nil
        doom-modeline-vcs-max-length   20))

;; ── Dashboard — crab splash ──────────────────────────────────────────────────
(defun my/doom-dashboard-crab ()
  (let* ((banner '("   __________  ____  _____ ______"
                   "  / ____/ __ \\/ __ \\/ ___// ____/"
                   " / / __/ / / / / / /\\__ \\/ __/  "
                   "/ /_/ / /_/ / /_/ /___/ / /___  "
                   "\\____/\\____/\\____//____/_____/  "
                   ""
                   "  geometric algebra · rust · analog RC"))
         (longest (apply #'max (mapcar #'length banner)))
         (pad (max 0 (/ (- (window-width) longest) 2))))
    (dolist (line banner)
      (insert (make-string pad ?\s)
              (propertize line 'face 'doom-dashboard-banner)
              "\n"))))

(after! doom-dashboard
  (setq +doom-dashboard-ascii-banner-fn #'my/doom-dashboard-crab))

;; ── Rust ─────────────────────────────────────────────────────────────────────
(after! rustic
  (setq rustic-format-on-save t
        rustic-lsp-client 'lsp-mode))

;; ── LSP ──────────────────────────────────────────────────────────────────────
(after! lsp-mode
  (setq lsp-ui-doc-enable          t
        lsp-ui-doc-position        'at-point
        lsp-ui-sideline-enable     t
        lsp-lens-enable            t))

;; ── Clipboard — WSL needs special handling ───────────────────────────────────
(when my/wslp
  (setq interprogram-cut-function
        (lambda (text &optional _push)
          (with-temp-buffer
            (insert text)
            (call-process-region (point-min) (point-max) "clip.exe" nil 0))))
  (setq interprogram-paste-function
        (lambda ()
          (shell-command-to-string "powershell.exe -command 'Get-Clipboard'"))))

;; ── Frame transparency ───────────────────────────────────────────────────────
(add-to-list 'default-frame-alist '(alpha-background . 92))

;; ── Dimmer — fade inactive windows ───────────────────────────────────────────
(after! dimmer
  (setq dimmer-fraction 0.25
        dimmer-adjustment-mode :foreground)
  (dimmer-mode t))

;; ── Good scroll — smooth scrolling ───────────────────────────────────────────
(after! good-scroll
  (good-scroll-mode t))

;; ── Rainbow delimiters ────────────────────────────────────────────────────────
(add-hook! (prog-mode) #'rainbow-delimiters-mode)

;; ── Indent guides ─────────────────────────────────────────────────────────────
(after! highlight-indent-guides
  (setq highlight-indent-guides-method 'character
        highlight-indent-guides-character ?\│
        highlight-indent-guides-responsive 'top))

;; ── Embark — contextual actions ───────────────────────────────────────────────
(after! embark
  (setq embark-prompter #'embark-completing-read-prompter))
(map! "C-." #'embark-act
      "C-;" #'embark-dwim)

;; ── Org-roam ──────────────────────────────────────────────────────────────────
(setq org-roam-directory "~/org/roam/")
(after! org-roam
  (org-roam-db-autosync-mode))
(map! :leader
      :desc "Roam find"    "nr" #'org-roam-node-find
      :desc "Roam insert"  "ni" #'org-roam-node-insert
      :desc "Roam buffer"  "nb" #'org-roam-buffer-toggle)

;; ── Projectile project discovery ────────────────────────────────────────────
(after! projectile
  (setq projectile-project-search-path '(("~/projects/" . 1))
        projectile-auto-discover t))

;; ── Org ───────────────────────────────────────────────────────────────────────
(setq org-directory "~/org/")


;; ── Keybindings ──────────────────────────────────────────────────────────────
(map! :leader
      :desc "Registers"    "fr" #'consult-register
      :desc "Find file"    "ff" #'find-file
      :desc "Live grep"    "fg" #'+default/search-project
      :desc "Buffers"      "fb" #'consult-buffer
      :desc "Rename tab"   "tr" #'+workspace/rename
      :desc "New tab"      "tn" #'+workspace/new)

;; ── Markdown preview ─────────────────────────────────────────────────────────
(after! markdown-mode
  (setq markdown-split-window-direction 'right))
(after! grip-mode
  (setq grip-binary-path (expand-file-name "~/.local/bin/grip")))
(map! :localleader
      :map markdown-mode-map
      :desc "Grip preview" "p" #'grip-mode)

;; ── Embedded / GDB ───────────────────────────────────────────────────────────
(after! dap-mode
  ;; GooseSteel STM32F413ZH via J-Link (attach — server started externally)
  (dap-register-debug-template "GooseSteel · STM32F413ZH (J-Link)"
    (list :type "gdb"
          :request "attach"
          :name "GooseSteel · STM32F413ZH (J-Link)"
          :gdbpath "/opt/homebrew/bin/arm-none-eabi-gdb"
          :program (expand-file-name
                    "build/stm32f413zh/GooseSteel-stm32f413zh-latest.elf"
                    "~/projects/goose-steel/repo")
          :target "localhost:2331"
          :cwd (expand-file-name "~/projects/goose-steel/repo")))

  ;; Generic J-Link RISC-V attach
  (dap-register-debug-template "J-Link RISC-V"
    (list :type "gdb"
          :request "attach"
          :name "J-Link RISC-V"
          :gdbpath "riscv64-unknown-elf-gdb"
          :target "localhost:2331")))

;; GDB many-windows (TUI-style multi-pane layout)
(map! :leader
      :desc "GDB many windows" "og" #'gdb-many-windows)

;; ── evil-surround ─────────────────────────────────────────────────────────────
(after! evil-surround
  (global-evil-surround-mode 1))

;; ── devdocs ───────────────────────────────────────────────────────────────────
(after! devdocs
  (map! :leader
        :desc "DevDocs lookup" "sd" #'devdocs-lookup))

;; ── git-timemachine ───────────────────────────────────────────────────────────
(map! :leader
      :desc "Git time machine" "gt" #'git-timemachine)

;; ── consult-dir ───────────────────────────────────────────────────────────────
(after! consult-dir
  (map! :leader
        :desc "Jump to dir" "fD" #'consult-dir))

;; ── aidermacs ────────────────────────────────────────────────────────────────
(after! aidermacs
  (setq aidermacs-aider-command "/opt/homebrew/bin/aider"
        aidermacs-extra-args '("--model" "ollama/qwen3.5:9b"
                               "--ollama-api-base" "http://localhost:11434"
                               "--no-auto-commits"))
  (add-to-list 'display-buffer-alist
               '("\\*aider.*"
                 (display-buffer-in-side-window)
                 (side . left)
                 (window-width . 80))))

;; ── GitHub Copilot ───────────────────────────────────────────────────────────
;; Register autoloads so M-x copilot-login works before a code file is opened
(autoload 'copilot-login "copilot" "Login to Copilot." t)
(autoload 'copilot-diagnose "copilot" "Diagnose Copilot." t)
(autoload 'copilot-panel-complete "copilot" "Open Copilot Panel." t)
(autoload 'copilot-chat "copilot-chat" "Open Copilot Chat." t)
(autoload 'copilot-chat-send-region "copilot-chat" "Send region to Copilot Chat." t)

(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ;; accept
              ("<tab>"    . copilot-accept-completion)
              ("TAB"      . copilot-accept-completion)
              ("C-TAB"    . copilot-accept-completion-by-word)
              ("C-<tab>"  . copilot-accept-completion-by-word)
              ;; cycle through suggestions
              ("M-n"      . copilot-next-completion)
              ("M-p"      . copilot-previous-completion)
              ;; dismiss
              ("C-g"      . copilot-clear-overlay))
  :init
  ;; Doom sets user-emacs-directory to .local/cache/, which makes the default
  ;; copilot-install-dir resolve to a non-existent .cache/.cache/copilot path.
  ;; Setting it here in :init ensures it's bound before the defcustom runs.
  (setq copilot-install-dir (expand-file-name "copilot" doom-cache-dir))
  :config
  (setq copilot-enable-predicates '(evil-insert-state-p))
  (setq copilot-indent-offset-warning-disable t)
  (setq copilot-completion-model "gpt-5.3-codex")
  ;; Chat needs an explicit model id (server rejects nil); Sonnet 4.6 is best for explaining code
  (setq copilot-chat-model "claude-sonnet-4.6"))

;; No line numbers in Copilot chat buffer
(add-hook 'copilot-chat-mode-hook (lambda () (display-line-numbers-mode -1)))

;; copilot--workspace-root runs inside the *Copilot Chat* buffer which has no
;; project association. Fall back to the source buffer's root so Copilot chat
;; knows which workspace is open.
(after! copilot
  (defadvice! my/copilot--workspace-root-via-source (orig-result)
    :filter-return #'copilot--workspace-root
    (or orig-result
        (when-let* ((src (and (boundp 'copilot-chat--source-buffer)
                              copilot-chat--source-buffer))
                    ((buffer-live-p src)))
          (with-current-buffer src
            (copilot--workspace-root)))))
            
  (defun copilot-chat-display ()
    "Display the Copilot Chat buffer."
    (interactive)
    (let ((chat-buf (get-buffer-create copilot-chat--buffer-name)))
      (unless (buffer-live-p chat-buf)
        (user-error "Copilot Chat is not active"))
      (with-current-buffer chat-buf
        (unless (derived-mode-p 'copilot-chat-mode)
          (copilot-chat-mode)))
      (display-buffer chat-buf))))

;; ── Claude CLI + AGI CLI right-side panels ───────────────────────────────────
(defun my/cli-panel-toggle (buf-name command)
  "Toggle a right-side vterm panel running COMMAND."
  (let* ((root (or (and (fboundp 'projectile-project-root) (projectile-project-root))
                   default-directory))
         (buf  (get-buffer buf-name))
         (win  (and buf (get-buffer-window buf))))
    (cond
     (win (delete-window win))
     (buf (display-buffer buf
                          '((display-buffer-in-side-window)
                            (side . right) (window-width . 0.40))))
     (t
      (let* ((src-win (selected-window))
             (src-buf (current-buffer))
             (new-buf (get-buffer-create buf-name)))
        (with-current-buffer new-buf
          (let ((default-directory root))
            (vterm-mode)))
        (display-buffer new-buf
                        '((display-buffer-in-side-window)
                          (side . right) (window-width . 0.40)))
        (set-window-buffer src-win src-buf)
        (with-current-buffer new-buf
          (vterm-send-string (concat command "\n"))))))))


(defun my/toggle-claude ()
  "Toggle Claude Code CLI panel."
  (interactive)
  (my/cli-panel-toggle "*claude-cli*" "claude"))

(defun my/claude-add-file ()
  "Send current file to the Claude CLI panel as context."
  (interactive)
  (when-let* ((file (buffer-file-name))
              (root (or (and (fboundp 'projectile-project-root) (projectile-project-root))
                        default-directory))
              (rel  (file-relative-name file root))
              (buf  (get-buffer "*claude-cli*")))
    (with-current-buffer buf
      (vterm-send-string (format "@%s\n" rel)))))

(defun my/toggle-agy ()
  "Toggle Antigravity CLI panel."
  (interactive)
  (my/cli-panel-toggle "*agy-cli*" "agy"))

(defun my/agy-add-file ()
  "Send current file to the AGI CLI panel as context."
  (interactive)
  (when-let* ((file (buffer-file-name))
              (root (or (and (fboundp 'projectile-project-root) (projectile-project-root))
                        default-directory))
              (rel  (file-relative-name file root))
              (buf  (get-buffer "*agy-cli*")))
    (with-current-buffer buf
      (vterm-send-string (format "/add %s\n" rel)))))

;; ── AI tools (aider + copilot) under one SPC A prefix ────────────────────────
(map! :leader
      (:prefix ("A" . "ai")
       :desc "Claude CLI panel"    "C" #'my/toggle-claude
       :desc "Claude add file"     "F" #'my/claude-add-file
       :desc "AGI CLI panel"       "G" #'my/toggle-agy
       :desc "AGI add file"        "H" #'my/agy-add-file
       :desc "Aider run"           "a" #'aidermacs-run
       :desc "Aider add file"      "f" #'aidermacs-add-current-file
       :desc "Aider send region"   "s" #'aidermacs-send-block-or-region
       :desc "Aider reset"         "q" #'aidermacs-reset
       (:prefix ("c" . "copilot")
        :desc "Trigger completion" "c" #'copilot-complete
        :desc "Login"              "l" #'copilot-login
        :desc "Logout"             "o" #'copilot-logout
        :desc "Diagnose"           "d" #'copilot-diagnose
        :desc "Select cmpl model"  "m" #'copilot-select-completion-model
        :desc "Panel complete"     "p" #'copilot-panel-complete
        :desc "Chat"               "t" #'copilot-chat
        :desc "Chat send region"   "r" #'copilot-chat-send-region
        :desc "Chat reset"         "x" #'copilot-chat-reset
        :desc "Chat model"         "M" #'copilot-chat-select-model)))

(map! :leader :desc "Toggle Copilot" "tc" #'copilot-mode)

