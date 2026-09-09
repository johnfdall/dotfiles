;;; dotfiles-mojo.el --- Mojo: build, run, format and debug -*- lexical-binding: t; -*-
(require 'project)
(require 'compile)
(require 'json)
(require 'mojo-ts-mode)
(require 'dotfiles-build)
(declare-function dap-register-debug-provider "dap-mode")
(declare-function dap-debug "dap-mode")

(defconst dotfiles-mojo-file-regexp "\\.\\(?:mojo\\|🔥\\)\\'")

(defun dotfiles-mojo-directory ()
  "Find the closest pixi/Mojo project, falling back to the Emacs project root."
  (or (locate-dominating-file
       default-directory
       (lambda (dir)
         (seq-some (lambda (f) (file-exists-p (expand-file-name f dir)))
                   '("pixi.toml" "mojoproject.toml" "pyproject.toml"))))
      (when-let* ((project (project-current))) (project-root project))
      default-directory))

(defun dotfiles-mojo-source (&optional prompt)
  "The Mojo file to act on: this buffer's file, or one read with PROMPT."
  (if (and buffer-file-name
           (string-match-p dotfiles-mojo-file-regexp buffer-file-name)
           (not prompt))
      buffer-file-name
    (read-file-name (or prompt "Mojo file: ") (dotfiles-mojo-directory) nil t nil
                    (lambda (f) (or (file-directory-p f)
                                    (string-match-p dotfiles-mojo-file-regexp f))))))

(defun dotfiles-mojo-command (command &optional source)
  "Run editable mojo COMMAND on SOURCE in the closest project directory."
  (let* ((default-directory (dotfiles-mojo-directory))
         (file (file-relative-name (or source (dotfiles-mojo-source))
                                   default-directory)))
    (compile (read-shell-command
              "Command: " (format "mojo %s %s" command (shell-quote-argument file))))))

(defun dotfiles-mojo-build () (interactive) (dotfiles-mojo-command "build"))
(defun dotfiles-mojo-build-debug ()
  "Build unoptimised with full debug info, for `dotfiles-mojo-debug'."
  (interactive)
  (dotfiles-mojo-command "build --debug-level full --no-optimization"))
(defun dotfiles-mojo-run () (interactive) (dotfiles-mojo-command "run"))

(defun dotfiles-mojo-test ()
  "Run a TestSuite program: this file when it is a test, otherwise ask.
Mojo 1.0 removed `mojo test'; tests are ordinary programs whose main
calls TestSuite.run."
  (interactive)
  (let ((test-p (and buffer-file-name
                     (string-match-p "\\(?:\\`\\|/\\)test_[^/]*\\.\\(?:mojo\\|🔥\\)\\'\\|_test\\.\\(?:mojo\\|🔥\\)\\'"
                                     buffer-file-name))))
    (dotfiles-mojo-command "run" (if test-p buffer-file-name
                                   (dotfiles-mojo-source "Test file to run: ")))))

(defun dotfiles-mojo-format ()
  "Format this file with `mojo format' and reload it."
  (interactive)
  (unless buffer-file-name (user-error "Save the buffer to a file first"))
  (when (buffer-modified-p) (save-buffer))
  (with-temp-buffer
    (let ((status (call-process "mojo" nil t nil "format" "-q" buffer-file-name)))
      (unless (eq status 0)
        (user-error "mojo format failed: %s" (string-trim (buffer-string))))))
  (revert-buffer t t t))

;;;; Debugging through mojo-lldb-dap

(defun dotfiles-mojo-sdk-prefix ()
  "The Mojo SDK root holding bin/ and lib/, resolved through pixi's launcher."
  (when-let* ((launcher (executable-find "mojo-lldb-dap")))
    (let* ((launcher (file-truename launcher))
           (config (expand-file-name
                    (concat (file-name-nondirectory launcher) ".json")
                    (expand-file-name "trampoline_configuration"
                                      (file-name-directory launcher))))
           (exe (if (file-readable-p config)
                    (alist-get 'exe (json-read-file config))
                  launcher)))
      (file-name-directory (directory-file-name (file-name-directory exe))))))

(defun dotfiles-mojo-lldb-plugin ()
  "Path to the Mojo LLDB plugin, or nil when it cannot be found."
  (when-let* ((prefix (dotfiles-mojo-sdk-prefix))
              (plugin (expand-file-name "lib/libMojoLLDB.dylib" prefix)))
    (and (file-exists-p plugin) plugin)))

(defun dotfiles-mojo--default (conf key value)
  "Set KEY to VALUE in the debug configuration CONF unless already present."
  (if (plist-member conf key) conf (plist-put conf key value)))

(defun dotfiles-mojo--debug-provider (conf)
  "Complete CONF the way the Mojo VS Code extension configures lldb-dap."
  (let ((adapter (or (executable-find "mojo-lldb-dap")
                     (user-error "mojo-lldb-dap is missing from PATH")))
        (plugin (dotfiles-mojo-lldb-plugin)))
    (dotfiles-mojo--default conf :dap-server-path (list adapter "--repl-mode" "variable"))
    ;; `?' keeps a command quiet on success; `!' aborts the session on failure.
    (dotfiles-mojo--default
     conf :initCommands
     (vconcat (when plugin (list (format "?!plugin load '%s'" plugin)))
              ["?settings set target.show-hex-variable-values-with-leading-zeroes false"
               "?settings set target.process.optimization-warnings false"]))
    (dotfiles-mojo--default conf :customFrameFormat
                            "${function.name-with-args}{${frame.is-artificial} [artificial]}")
    (dotfiles-mojo--default conf :enableAutoVariableSummaries t)
    (dotfiles-mojo--default conf :enableSyntheticChildDebugging t)
    (dotfiles-mojo--default conf :commandEscapePrefix ":")
    (dotfiles-mojo--default conf :timeout 300)
    conf))

(with-eval-after-load 'dap-mode
  (dap-register-debug-provider "mojo-lldb" #'dotfiles-mojo--debug-provider))

(defun dotfiles-mojo-debug (program)
  "Debug the Mojo executable PROGRAM (built with debug info) with mojo-lldb-dap."
  (interactive
   (list (read-file-name "Debug executable (build with debug info first): "
                         (dotfiles-mojo-directory) nil t)))
  (require 'dap-mode)
  (when (file-directory-p program) (user-error "Select the built executable"))
  (dap-debug (list :type "mojo-lldb" :request "launch"
                   :name (file-name-nondirectory program)
                   :program (expand-file-name program)
                   :cwd (dotfiles-mojo-directory)
                   :args [] :stopOnEntry :json-false)))

(defun dotfiles-mojo-attach (pid)
  "Attach mojo-lldb-dap to the running Mojo process PID."
  (interactive "nMojo process PID: ")
  (require 'dap-mode)
  (dap-debug (list :type "mojo-lldb" :request "attach"
                   :name (format "Mojo attach %d" pid) :pid pid)))

;;;; Wiring

(defconst dotfiles-mojo-commands
  '(:build dotfiles-mojo-build
    :build-alt dotfiles-mojo-build-debug
    :test dotfiles-mojo-test
    :run dotfiles-mojo-run
    :debug dotfiles-mojo-debug
    :attach dotfiles-mojo-attach
    :format dotfiles-mojo-format))

(defun dotfiles-mojo-setup ()
  "Select the Mojo toolchain and use compiler output for diagnostics."
  (setq dotfiles-build-commands dotfiles-mojo-commands)
  (when (bound-and-true-p lsp-mode) (lsp-disconnect))
  (when (bound-and-true-p flycheck-mode) (flycheck-mode -1))
  (when (bound-and-true-p flymake-mode) (flymake-mode -1)))

(add-hook 'mojo-ts-mode-hook #'dotfiles-mojo-setup)
;; Also remove the previous auto-start hook when reloading this file live.
(remove-hook 'mojo-ts-mode-hook #'lsp-deferred)

(provide 'dotfiles-mojo)
;;; dotfiles-mojo.el ends here
