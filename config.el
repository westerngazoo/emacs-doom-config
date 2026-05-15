;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; ── Identity ────────────────────────────────────────────────────────────────
(setq user-full-name  "Gustavo Delgadillo"
      user-mail-address "gustavo.delgadillo@gmail.com")

;; ── Platform detection ──────────────────────────────────────────────────────
(defvar my/macp   (eq system-type 'darwin))
(defvar my/linuxp (eq system-type 'gnu/linux))
(defvar my/wslp   (and my/linuxp
                       (file-exists-p "/proc/sys/fs/binfmt_misc/WSLInterop")))

;; ── Font ────────────────────────────────────────────────────────────────────
(setq doom-font (font-spec
                 :family (if my/macp "JetBrainsMono Nerd Font"
                           "JetBrainsMono Nerd Font Mono")
                 :size (if my/macp 15 14))
      doom-variable-pitch-font (font-spec :family "JetBrainsMono Nerd Font" :size 13)
      doom-big-font (font-spec :family "JetBrainsMono Nerd Font" :size 20))

;; ── Theme — oxocarbon palette on doom-one base ──────────────────────────────
(setq doom-theme 'doom-one)

(add-hook! 'doom-load-theme-hook
  (custom-set-faces!
    '(default                  :background "#262626" :foreground "#f2f4f8")
    '(fringe                   :background "#262626")
    '(hl-line                  :background "#333333")
    '(region                   :background "#444444")
    '(cursor                   :background "#42be65")
    '(vertical-border          :foreground "#444444")
    '(line-number              :background "#262626" :foreground "#6e6e6e")
    '(line-number-current-line :background "#262626" :foreground "#f2f4f8" :weight bold)
    '(font-lock-keyword-face       :foreground "#4589ff" :weight bold)
    '(font-lock-function-name-face :foreground "#82cfff" :weight bold)
    '(font-lock-type-face          :foreground "#3ddbd9")
    '(font-lock-variable-name-face :foreground "#f2f4f8" :weight normal)
    '(font-lock-string-face        :foreground "#ff4444")
    '(font-lock-comment-face       :foreground "#f2f4f8" :weight normal :slant normal)
    '(font-lock-doc-face           :foreground "#f2f4f8" :weight normal :slant normal)
    '(font-lock-constant-face      :foreground "#ff7eb6")
    '(font-lock-builtin-face       :foreground "#82cfff")
    '(mode-line                :background "#333333" :foreground "#f2f4f8")
    '(mode-line-inactive       :background "#2a2a2a" :foreground "#6e6e6e")))

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
      :desc "File tree"    "e"  #'+treemacs/toggle
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
        highlight-indent-guides-responsive 'top)
  (custom-set-faces!
    '(highlight-indent-guides-character-face     :foreground "#3a3a3a")
    '(highlight-indent-guides-top-character-face :foreground "#6e6e6e")))

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

;; ── Tree-sitter faces (Rust, C++) ────────────────────────────────────────────
(add-hook! 'doom-load-theme-hook
  (custom-set-faces!
    '(tree-sitter-hl-face:keyword          :foreground "#4589ff" :weight bold)
    '(tree-sitter-hl-face:function         :foreground "#82cfff" :weight bold)
    '(tree-sitter-hl-face:function.call    :foreground "#82cfff")
    '(tree-sitter-hl-face:function.macro   :foreground "#82cfff" :weight bold)
    '(tree-sitter-hl-face:method           :foreground "#82cfff" :weight bold)
    '(tree-sitter-hl-face:method.call      :foreground "#82cfff")
    '(tree-sitter-hl-face:type             :foreground "#3ddbd9")
    '(tree-sitter-hl-face:type.builtin     :foreground "#3ddbd9")
    '(tree-sitter-hl-face:string           :foreground "#ff4444")
    '(tree-sitter-hl-face:string.special   :foreground "#ff4444")
    '(tree-sitter-hl-face:comment          :foreground "#f2f4f8" :weight normal :slant normal)
    '(tree-sitter-hl-face:doc              :foreground "#f2f4f8" :weight normal :slant normal)
    '(tree-sitter-hl-face:constant         :foreground "#ff7eb6")
    '(tree-sitter-hl-face:constant.builtin :foreground "#ff7eb6")
    '(tree-sitter-hl-face:variable         :foreground "#f2f4f8" :weight normal)
    '(tree-sitter-hl-face:variable.builtin :foreground "#f2f4f8")
    '(tree-sitter-hl-face:property         :foreground "#f2f4f8")
    '(tree-sitter-hl-face:operator         :foreground "#c6c6c6")
    '(tree-sitter-hl-face:punctuation      :foreground "#c6c6c6")
    '(tree-sitter-hl-face:number           :foreground "#ff7eb6")))

;; ── Keybindings ──────────────────────────────────────────────────────────────
(map! :leader
      :desc "Registers"    "fr" #'consult-register
      :desc "Find file"    "ff" #'find-file
      :desc "Live grep"    "fg" #'+default/search-project
      :desc "Buffers"      "fb" #'consult-buffer
      :desc "Rename tab"   "tr" #'+workspace/rename
      :desc "New tab"      "tn" #'+workspace/new)
