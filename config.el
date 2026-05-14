;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; ── Identity ────────────────────────────────────────────────────────────────
(setq user-full-name  "Gustavo Delgadillo"
      user-mail-address "gustavo.delgadillo@gmail.com")

;; ── Platform detection ──────────────────────────────────────────────────────
(defvar my/macp   (eq system-type 'darwin))
(defvar my/linuxp (eq system-type 'gnu/linux))
(defvar my/wslp   (and my/linuxp
                       (string-match-p "WSL\\|microsoft"
                         (shell-command-to-string "uname -r"))))

;; ── Font ────────────────────────────────────────────────────────────────────
(setq doom-font (font-spec
                 :family (if my/macp "JetBrainsMono Nerd Font"
                           "JetBrainsMono Nerd Font Mono")
                 :size (if my/macp 14 13))
      doom-variable-pitch-font (font-spec :family "JetBrainsMono Nerd Font" :size 13)
      doom-big-font (font-spec :family "JetBrainsMono Nerd Font" :size 20))

;; ── Theme — cyberpunk dark ───────────────────────────────────────────────────
(setq doom-theme 'doom-city-lights)

;; Override highlights for cyberpunk feel after theme loads
(add-hook! 'doom-load-theme-hook
  (custom-set-faces!
    ;; Teal/cyan keywords like the image
    '(font-lock-keyword-face       :foreground "#5DE4C7" :weight bold)
    '(font-lock-function-name-face :foreground "#FFFAC2" :weight bold)
    '(font-lock-string-face        :foreground "#ADD7FF")
    '(font-lock-comment-face       :foreground "#3B5268" :slant italic)
    '(font-lock-type-face          :foreground "#5DE4C7")
    '(font-lock-constant-face      :foreground "#E4F0FB")
    ;; Amber line numbers like the terminal in the image
    '(line-number              :foreground "#3B5268")
    '(line-number-current-line :foreground "#FFCC00" :weight bold)
    ;; Git gutter colors
    '(vc-gutter:added    :foreground "#5FB770")
    '(vc-gutter:modified :foreground "#FF9E3B")
    '(vc-gutter:removed  :foreground "#FF5C57")))

;; ── Line numbers ─────────────────────────────────────────────────────────────
(setq display-line-numbers-type 'relative)

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
      :desc "File tree"    "e"  #'treemacs
      :desc "Claude Code"  "cc" (cmd! (vterm) (vterm-send-string "claude\n")))

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
