;; displays the time in the status bar
(display-time)

;; do not make backup files
(setq make-backup-files nil)

;; Goto-line short-cut key
(global-set-key "\C-l" 'goto-line)

;; Set debuggin to true, make errors more verbose
(setq debug-on-error t)

;; Start up a named shell in the current buffer
(defun start-shell (name)
  "Starts a shell buffer with the given name in the current window."
  (switch-to-buffer name)
  (shell name))

;; Define 2 shells to be used on startup
(defun start-shell1 ()
  (interactive)
  (start-shell "shell1"))
(defun start-shell2 ()
  (interactive)
  (start-shell "shell2"))

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

;; use hippie expand
;;(global-set-key "\M-/" 'hippie-expand-case-sensitive)
(global-set-key "\C-x\C-x" 'hippie-expand)

;; set default ccmode indent to 4
(setq c-default-style "bsd"
      c-basic-offset 4)

;; change indents from tabs to spaces
(setq c-mode-hook
    (function (lambda ()
                (setq indent-tabs-mode nil)
                (setq c-indent-level 4))))
(setq objc-mode-hook
    (function (lambda ()
                (setq indent-tabs-mode nil)
                (setq c-indent-level 4))))
(setq c++-mode-hook
    (function (lambda ()
                (setq indent-tabs-mode nil)
                (setq c-indent-level 4))))

;; indents the whole file
(defun indent-all ()
  "indent whole buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))

;; python mode
(add-to-list 'load-path "~/.emacs.d/python-mode/") 
(setq py-install-directory "~/.emacs.d/python-mode/")
(require 'python-mode)

;; org-mode! for note taking and task completion
(require 'org-install)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)

