;;; dotfiles-csharp.el --- Roslyn stdio client -*- lexical-binding: t; -*-
(require 'lsp-mode)
(require 'cl-lib)

(defun dotfiles-roslyn-open-project (_workspace)
  "Open a solution, or the nearest standalone C# project, in Roslyn."
  (let* ((start default-directory)
         (solution-dir
          (locate-dominating-file
           start (lambda (dir) (directory-files dir nil "\\.slnx?\\'"))))
         (project-dir
          (unless solution-dir
            (locate-dominating-file
             start (lambda (dir) (directory-files dir nil "\\.csproj\\'")))))
         (files (cond (solution-dir (directory-files solution-dir t "\\.slnx?\\'"))
                      (project-dir (directory-files project-dir t "\\.csproj\\'"))))
         (file (if (length= files 1) (car files)
                 (when files (completing-read "Roslyn solution/project: " files nil t)))))
    (when file
      (if solution-dir
          (lsp-notify "solution/open" (list :solution (lsp--path-to-uri file)))
        (lsp-notify "project/open" (list :projects (vector (lsp--path-to-uri file))))))))

;; The installed modern Roslyn tool supports stdio.  lsp-mode's bundled
;; Roslyn client still targets the older DLL/named-pipe distribution.
(lsp-register-client
 (make-lsp-client
  :new-connection (lsp-stdio-connection '("roslyn-language-server" "--stdio"))
  :activation-fn (lsp-activate-on "csharp")
  :major-modes '(csharp-mode csharp-ts-mode)
  :priority 10
  :server-id 'dotfiles-roslyn
  :initialized-fn #'dotfiles-roslyn-open-project
  :notification-handlers
  (let ((handlers (make-hash-table :test 'equal)))
    (puthash "workspace/projectInitializationComplete"
             (lambda (&rest _) (message "Roslyn project loaded")) handlers)
    handlers)))
(provide 'dotfiles-csharp)
