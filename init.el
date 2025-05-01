;; Ensure use-package is installed
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Setup package repositories (MELPA)
(require 'package)
(setq package-archives '(("melpa" . "http://melpa.org/packages/")
                         ("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)

;; This allows loading our custom config files.
(setq load-path (cons "~/.emacs.d/custom" load-path))

;; Load Windows specific settings if on Windows
(when (eq system-type 'windows-nt)
  (load "windows-settings.el"))

;; Load personal customizations
(load "personalizations.el")

;; Load custom shell settings
(load "shell-settings.el")

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

;; go mode (if installed)
(use-package go-mode
  :ensure t ; Install if not present
  :hook (go-mode . (lambda () (add-hook 'before-save-hook #'gofmt-before-save nil t) (local-set-key (kbd "M-.") #'godef-jump))) ; Recommended hooks from go-mode.el documentation
  :bind (:map go-mode-map ; Bind keys specific to go-mode
              ("C-c C-a" . go-import-add) ("C-c C-j" . godef-jump) ("C-x 4 C-c C-j" . godef-jump-other-window) ("C-c C-d" . godef-describe)))

;; adds the clangformat tool for c++ formatting.
;; Need to install the clang-format cmd line tool
;; seperately. Try apt-cache search clang-format
;; to see available packages on ubuntu.
(use-package clang-format
  :ensure t ; Install if not present
  :bind (([C-M-tab] . clang-format-region)))

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

;; Install lsp-mode and rustic via package.el
;; install rustic for rust dev
;; note that this requires lsp-mode and rust-analyzer
;; rustup component add rust-src
;; rustup component add rust-analyzer
(use-package lsp-mode :ensure t)
(use-package rustic :ensure t)

;; Use IDO for completions
(use-package ido ; ido is available on GNU ELPA
  :ensure t ; Install if not present
  :init (ido-mode t)
  :custom
  (ido-enable-flex-matching t)
  (ido-enable-regexp t))
