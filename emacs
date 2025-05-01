;; Ensure use-package is installed
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Setup package repositories (MELPA)
(require 'package)
(setq package-archives '(("melpa" . "http://melpa.org/packages/")
                         ("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)

;; copy line rather than kill
(defun copy-line (arg)
    "Copy lines (as many as prefix argument) in the kill ring.
      Ease of use features:
      - Move to start of next line.
      - Appends the copy on sequential calls.
      - Use newline as last char even on the last line of the buffer.
      - If region is active, copy its lines."
    (interactive "p")
    (let ((beg (line-beginning-position))
          (end (line-end-position arg)))
      (when mark-active
        (if (> (point) (mark))
            (setq beg (save-excursion (goto-char (mark)) (line-beginning-position)))
          (setq end (save-excursion (goto-char (mark)) (line-end-position)))))
      (if (eq last-command 'copy-line)
          (kill-append (buffer-substring beg end) (< end beg))
        (kill-ring-save beg end)))
    (kill-append "\n" nil)
    (beginning-of-line (or (and arg (1+ arg)) 2))
    (if (and arg (not (= 1 arg))) (message "%d lines copied" arg)))

;; use M-k for copy-line instead of kill line. I know this breaks the M/C pattern, but
;; I never use kill sentence.
(global-set-key (kbd "M-k") 'copy-line)

;; shortcuts for end and begining of buffer
;; Note: If getting a preedit area on c-., this is a gsettings issue. Check it with:
;; gsettings get org.freedesktop.ibus.panel.emoji hotkey
;; and reset it with:
;; gsettings set org.freedesktop.ibus.panel.emoji hotkey "@as []"
(global-set-key (kbd "C-.") 'end-of-buffer)
(global-set-key (kbd "C-,") 'beginning-of-buffer)

;; General Emacs settings
(display-time)
(setq make-backup-files nil)
(setq inhibit-startup-screen t)
(setq initial-frame-alist '((fullscreen . maximized)))
(show-paren-mode 1) ; match parens
(setq column-number-mode t) ; show column number

;; Set debugging to true, make errors more verbose
;; (setq debug-on-error t)

;; Goto-line short-cut key
(global-set-key "\C-l" 'goto-line)

;; Use bind-key for managing keybindings
(use-package bind-key
  :ensure t
  :bind* (("C-j" . copy-region-as-kill) ; shortcut for copy-region-as kill that overrides all other modes.
          ("C-o" . other-window) ; global shortcut for other-window
          ("C-c c" . compile))) ; global shortcut for compilation

;; Use IDO for completions
(use-package ido
  :ensure t
  :init (ido-mode t)
  :custom
  (ido-enable-flex-matching t)
  (ido-enable-regexp t))

;; use hippie expand
(global-set-key "\C-x\C-x" 'hippie-expand)

;; windows specific settings
(when (eq system-type 'windows-nt)
  ;; start fullscreen in windows
  (w32-send-sys-command 61488)
  ;; set python unbuffered otherwise we dont flush prints
  (setenv "PYTHONUNBUFFERED" "x")
)

;; Start up a named shell in the current buffer
(defun start-shell (name)
  "Starts a shell buffer with the given name in the current window."
  (interactive "BName for new shell:")
  (switch-to-buffer name)
  (shell name))

;; Define 2 shells to be used on startup
;; use eshell in windows, otherwise shell from start-shell
(defun start-shell1 ()
  (interactive)
  (if (eq system-type 'windows-nt)
      (eshell 1)
    (start-shell "shell1"))
)

(defun start-shell2 ()
  (interactive)
  (if (eq system-type 'windows-nt)
      (eshell 2)
    (start-shell "shell2"))
)

;; set the keybinding so that f3 & f4 will start their own shells
(global-set-key [f3] 'start-shell1)
(global-set-key [f4] 'start-shell2)

;; have either 1 or 2 shells come up on start up (1 if a file was opened)
(defun startup-2shells ()
  "Starts two shells with a horizontal split"
  (split-window-horizontally)
  (start-shell1)
  (other-window 1)
  (start-shell2)
  (other-window 1))

(defun startup-1shell ()
  "starts a shell with a horizontal split"
  (split-window-horizontally)
  (other-window 1)
  (start-shell1)
  (other-window 1))

(if (> (length command-line-args) 1)
    (startup-1shell)
  (startup-2shells))

;; set default ccmode indent to tabs
(setq c-default-style "linux"
      c-basic-offset 8
      tab-width 8
      indent-tabs-mode t)

;; set js indent to 2
(setq js-indent-level 2)

;; change indents from tabs to spaces
(setq c-mode-hook
    (function (lambda ()
                (setq indent-tabs-mode nil)
                (setq c-basic-offset 2)))) ; Use c-basic-offset for mode-specific indent
(setq objc-mode-hook
    (function (lambda ()
                (setq indent-tabs-mode nil)
                (setq c-basic-offset 2))))
(setq c++-mode-hook
    (function (lambda ()
                (setq indent-tabs-mode nil)
                (setq c-basic-offset 2))))

;; indents the whole file
(defun indent-all ()
  "indent whole buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil))
;; untabify is often not desired if indent-tabs-mode is nil, and indent-region handles tabs/spaces based on mode settings.
;; (untabify (point-min) (point-max))

;; go mode (if installed)
(when (file-directory-p "~/.emacs.d/go-mode")
  (use-package go-mode-load
    :load-path "~/.emacs.d/go-mode"
    :demand t ; Load eagerly as before
    :hook (go-mode . (lambda () (add-hook 'before-save-hook #'gofmt-before-save nil t) (local-set-key (kbd "M-.") #'godef-jump))) ; Recommended hooks from go-mode.el documentation
    :bind (:map go-mode-map ; Bind keys specific to go-mode
                ("C-c C-a" . go-import-add) ("C-c C-j" . godef-jump) ("C-x 4 C-c C-j" . godef-jump-other-window) ("C-c C-d" . godef-describe))))

;; adds the clangformat tool for c++ formatting.
;; Need to install the clang-format cmd line tool
;; seperately. Try apt-cache search clang-format
;; to see available packages on ubuntu.
(when (file-directory-p "~/.emacs.d/clang-format")
  (use-package clang-format
    :load-path "~/.emacs.d/clang-format"
    :demand t ; Load eagerly as before
    :bind (([C-M-tab] . clang-format-region))))

;; Start emacs server so emacsclient can be used
(server-start)

;; set VISUAL to emacsclient for use with server
;; Note: works for eshell only, bash users should export
;; EDITOR=emacsclient and ALTERNATE_EDITOR=emacs
(setenv "VISUAL" "emacsclient")

;; use a theme, requires emacs 24
(load-theme 'wombat t)


;; overrides comment color in our theme. Makes comments red.
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right. This block is fine as is.
 '(font-lock-comment-face ((t (:foreground "firebrick")))))

;; Install lsp-mode and rustic via package.el (use-package handles this with :ensure t)
(use-package lsp-mode :ensure t)
;; install rustic for rust dev
;; note that this requires lsp-mode and rust-analyzer
;; rustup component add rust-src
;; rustup component add rust-analyzer
(use-package rustic :ensure t)
