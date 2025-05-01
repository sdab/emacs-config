;; windows specific settings loaded from windows-settings.el
;; start fullscreen in windows
(w32-send-sys-command 61488)
;; set python unbuffered otherwise we dont flush prints
(setenv "PYTHONUNBUFFERED" "x")
