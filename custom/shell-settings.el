;; Custom shell settings loaded from custom/shell-settings.el

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

;; Logic to start 1 or 2 shells on startup based on command-line arguments
(if (> (length command-line-args) 1)
    (startup-1shell)
  (startup-2shells))
