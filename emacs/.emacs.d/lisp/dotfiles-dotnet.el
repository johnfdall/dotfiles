;;; dotfiles-dotnet.el --- Build, test, run and debug -*- lexical-binding: t; -*-
(require 'project)
(require 'compile)

(defun dotfiles-dotnet-directory ()
  "Find the closest .NET project, falling back to the Emacs project root."
  (or (locate-dominating-file
       default-directory (lambda (dir) (directory-files dir nil "\\.csproj\\'")))
      (when-let* ((project (project-current))) (project-root project))
      default-directory))

(defun dotfiles-dotnet-command (command)
  "Run editable dotnet COMMAND in the closest project directory."
  (let ((default-directory (dotfiles-dotnet-directory)))
    (compile (read-shell-command "Command: " (concat "dotnet " command)))))
(defun dotfiles-dotnet-build () (interactive) (dotfiles-dotnet-command "build"))
(defun dotfiles-dotnet-build-no-restore () (interactive) (dotfiles-dotnet-command "build --no-restore"))
(defun dotfiles-dotnet-test () (interactive) (dotfiles-dotnet-command "test"))
(defun dotfiles-dotnet-run () (interactive) (dotfiles-dotnet-command "run"))

(defun dotfiles-dotnet-debug (program)
  "Debug a built PROGRAM DLL with portable PDBs, using netcoredbg."
  (interactive
   (list (read-file-name "Debug DLL (build Debug first): "
                         (expand-file-name "bin/Debug/" (dotfiles-dotnet-directory))
                         nil t)))
  (require 'dap-netcore)
  (unless (executable-find "netcoredbg") (user-error "netcoredbg is missing from PATH"))
  (unless (string-equal (file-name-extension program) "dll")
    (user-error "Select the application DLL"))
  (dap-debug (list :type "coreclr" :request "launch" :mode "launch"
                   :name (file-name-base program)
                   :program (expand-file-name program)
                   :cwd (dotfiles-dotnet-directory)
                   :args [] :stopAtEntry :json-false :justMyCode t
                   :console "internalConsole")))

(defun dotfiles-dotnet-attach (pid)
  "Attach netcoredbg to .NET process PID."
  (interactive "n.NET process PID: ")
  (require 'dap-netcore)
  (dap-debug (list :type "coreclr" :request "attach" :mode "attach"
                   :name (format ".NET attach %d" pid) :processId pid)))

;; Keys live in dotfiles-build.el, which dispatches per language.
(provide 'dotfiles-dotnet)
