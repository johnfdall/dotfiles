;;; dotfiles-build.el --- Language-aware build, test, run and debug keys -*- lexical-binding: t; -*-

;; One set of keys drives every toolchain.  A major mode chooses its commands
;; by setting `dotfiles-build-commands' in its hook; buffers without a choice
;; (compilation output, Magit, Dired) reuse the commands of the last buffer
;; that had one, and the .NET commands before anything has been used.

(defvar dotfiles-build-default-commands
  '(:build dotfiles-dotnet-build
    :build-alt dotfiles-dotnet-build-no-restore
    :test dotfiles-dotnet-test
    :run dotfiles-dotnet-run
    :debug dotfiles-dotnet-debug
    :attach dotfiles-dotnet-attach
    :format lsp-format-buffer)
  "Commands used before any language-specific buffer has chosen its own.")

(defvar-local dotfiles-build-commands nil
  "Command plist for this buffer's language; see `dotfiles-build-default-commands'.")

(defvar dotfiles-build-last-commands nil
  "The command plist of the last buffer that ran a build command.")

(defun dotfiles-build-dispatch (key)
  "Run the command registered under KEY for the current language."
  (when dotfiles-build-commands
    (setq dotfiles-build-last-commands dotfiles-build-commands))
  (let ((command (or (plist-get dotfiles-build-commands key)
                     (plist-get dotfiles-build-last-commands key)
                     (plist-get dotfiles-build-default-commands key))))
    (unless command (user-error "No %s command for this buffer" key))
    (call-interactively command)))

(defun dotfiles-build () "Build with this buffer's toolchain." (interactive)
  (dotfiles-build-dispatch :build))
(defun dotfiles-build-alt () "Alternate build: C# without restore, Mojo with debug info." (interactive)
  (dotfiles-build-dispatch :build-alt))
(defun dotfiles-test () "Test with this buffer's toolchain." (interactive)
  (dotfiles-build-dispatch :test))
(defun dotfiles-run () "Run with this buffer's toolchain." (interactive)
  (dotfiles-build-dispatch :run))
(defun dotfiles-debug () "Debug with this buffer's toolchain." (interactive)
  (dotfiles-build-dispatch :debug))
(defun dotfiles-attach () "Attach a debugger with this buffer's toolchain." (interactive)
  (dotfiles-build-dispatch :attach))
(defun dotfiles-format () "Format with this buffer's toolchain." (interactive)
  (dotfiles-build-dispatch :format))

(global-set-key (kbd "C-c n b") #'dotfiles-build)
(global-set-key (kbd "C-c n t") #'dotfiles-test)
(global-set-key (kbd "C-c n r") #'dotfiles-run)
(global-set-key (kbd "C-c d d") #'dotfiles-debug)
(global-set-key (kbd "C-c d a") #'dotfiles-attach)
(global-set-key (kbd "C-c d b") #'dap-breakpoint-toggle)
(global-set-key (kbd "C-c d h") #'dap-hydra)

(provide 'dotfiles-build)
;;; dotfiles-build.el ends here
