;; Personalizations I like over vanilla emacs.

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

;; Use bind-key for managing keybindings
(use-package bind-key
  :ensure t ; Install if not present
  :bind* (("C-j" . copy-region-as-kill) ; shortcut for copy-region-as kill that overrides all other modes.
          ("C-o" . other-window) ; global shortcut for other-window
          ("C-c c" . compile))) ; global shortcut for compilation

;; use hippie expand
(global-set-key "\C-x\C-x" 'hippie-expand)

;; indents the whole file
(defun indent-all ()
  "indent whole buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil))
