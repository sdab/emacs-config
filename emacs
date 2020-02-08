;; displays the time in the status bar
(display-time)

;; do not make backup files
(setq make-backup-files nil)

;; Goto-line short-cut key
(global-set-key "\C-l" 'goto-line)

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
;; i never use kill sentence.
(global-set-key (kbd "M-k") 'copy-line)


;; Set debugging to true, make errors more verbose
;; (setq debug-on-error t)

;; shortcuts for end and begining of buffer
(global-set-key (kbd "C-.") 'end-of-buffer)
(global-set-key (kbd "C-,") 'beginning-of-buffer)

;; for bind-key command
(add-to-list 'load-path "~/.emacs.d/bind-key")
(require 'bind-key)
;; shortcut for copy-region-as kill that overrides all other modes.
(bind-key* "C-j" 'copy-region-as-kill)
;; global shortcut for other-window
(bind-key* "C-o" 'other-window)

;; windows specific settings
(when (eq system-type 'windows-nt)
  ;; start fullscreen in windows
  (w32-send-sys-command 61488)
  ;; set python unbuffered otherwise we dont flush prints
  (setenv "PYTHONUNBUFFERED" "x")
)

;; maximize in linux (harmless on windows?)
(custom-set-variables
 '(initial-frame-alist (quote ((fullscreen . maximized)))))

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

;; use hippie expand
;;(global-set-key "\M-/" 'hippie-expand-case-sensitive)
(global-set-key "\C-x\C-x" 'hippie-expand)

;; match parens
(show-paren-mode 1)

;; show column number
(setq column-number-mode t)

;; set default ccmode indent to 2
(setq c-default-style "bsd"
      c-basic-offset 2)

;; change indents from tabs to spaces
(setq c-mode-hook
    (function (lambda ()
                (setq indent-tabs-mode nil)
                (setq c-indent-level 2))))
(setq objc-mode-hook
    (function (lambda ()
                (setq indent-tabs-mode nil)
                (setq c-indent-level 2))))
(setq c++-mode-hook
    (function (lambda ()
                (setq indent-tabs-mode nil)
                (setq c-indent-level 2))))

;; indents the whole file
(defun indent-all ()
  "indent whole buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))

;; python mode
(when (file-directory-p "~/.emacs.d/python-mode")
  (add-to-list 'load-path "~/.emacs.d/python-mode/") 
  (setq py-install-directory "~/.emacs.d/python-mode/")
  (require 'python-mode)
)

;; go mode (if installed)
(when (file-directory-p "~/.emacs.d/go-mode")
  (add-to-list 'load-path "~/.emacs.d/go-mode")
  (require 'go-mode-load)
)

;; adds the clangformat tool for c++ formatting.
;; Need to install the clang-format cmd line tool
;; seperately. Try apt-cache search clang-format
;; to see available packages on ubuntu.
(when (file-directory-p "~/.emacs.d/clang-format")
  (add-to-list 'load-path "~/.emacs.d/clang-format")
  (require 'clang-format)
  (global-set-key [C-M-tab] 'clang-format-region)
)

;; org-mode! for note taking and task completion
(require 'org-install)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)

;; ido mode for awesome completions
(require 'ido)
(ido-mode t)

;; start emacs server so emacsclient can be used
(server-start)
;; set VISUAL to emacsclient for use with server
;; Note: works for eshell only, bash users should export
;; EDITOR=emacsclient and ALTERNATE_EDITOR=emacs
(setenv "VISUAL" "emacsclient")

;; use a theme, requires emacs 24
(load-theme 'wombat t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ido-enable-flex-matching t)
 '(ido-enable-regexp t)
 '(inhibit-startup-screen t))
;; overrides comment color in our theme. Makes comments red.
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(font-lock-comment-face ((t (:foreground "firebrick")))))
