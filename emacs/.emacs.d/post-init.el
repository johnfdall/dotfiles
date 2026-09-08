;;; post-init.el --- C# and Mojo development -*- no-byte-compile: t; lexical-binding: t; -*-
(require 'use-package)
(add-to-list 'load-path (expand-file-name "lisp" minimal-emacs-user-directory))
(setq use-package-always-ensure t
      custom-file (expand-file-name "custom.el" user-emacs-directory)
      auto-save-default t
      read-process-output-max (* 1024 1024))
(load-theme 'modus-vivendi t)
(setq-default indent-tabs-mode nil tab-width 2 truncate-lines t)
(setq c-basic-offset 2
      csharp-indent-level 2
      display-line-numbers-type 'relative
      select-enable-clipboard t
      completion-ignore-case t
      read-buffer-completion-ignore-case t
      case-fold-search t)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(savehist-mode 1)
(save-place-mode 1)
(recentf-mode 1)
(global-auto-revert-mode 1)
(column-number-mode 1)
(show-paren-mode 1)
(winner-mode 1)
(which-key-mode 1)

(use-package exec-path-from-shell
  :demand t
  :config
  (setq exec-path-from-shell-arguments '("-l"))
  (exec-path-from-shell-copy-envs '("PATH" "DOTNET_ROOT")))
(dolist (dir '("~/.local/bin" "~/.dotnet" "~/.dotnet/tools" "~/.pixi/bin"
               "/opt/homebrew/bin"))
  (let ((path (expand-file-name dir)))
    (add-to-list 'exec-path path)
    (setenv "PATH" (concat path path-separator (getenv "PATH")))))

(use-package vertico :init (vertico-mode 1))
(use-package marginalia :init (marginalia-mode 1))
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion)))))
(use-package consult
  :bind (("C-c s" . consult-ripgrep)
         ("C-c i" . consult-imenu)
         ("C-c b" . consult-buffer)))
(use-package company
  :hook (prog-mode . company-mode)
  :custom (company-idle-delay 0.15) (company-minimum-prefix-length 1))
(use-package yasnippet :hook (prog-mode . yas-minor-mode))
(use-package yasnippet-snippets :after yasnippet)
(use-package magit :bind ("C-c g" . magit-status))
(use-package expand-region
  :bind (("C-=" . er/expand-region)
         ("C-M-=" . er/contract-region)))
(use-package treemacs :bind ("C-c e" . treemacs))
(use-package olivetti
  :commands olivetti-mode
  :custom (olivetti-body-width 130))
(use-package evil
  :demand t
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-undo-system 'undo-redo)
  :config
  (evil-mode 1)
  (require 'dotfiles-evil))
(use-package evil-collection
  :after evil
  :config (evil-collection-init))
(use-package evil-surround
  :after evil
  :config (global-evil-surround-mode 1))
(use-package evil-commentary
  :after evil
  :config (evil-commentary-mode 1))
(use-package move-text :after evil)
(defun dotfiles-diagnostic-faces ()
  "Distinguish reported problems without marking optional refactorings."
  (set-face-attribute 'flycheck-error nil
                      :underline '(:style wave :color "#ff5f59"))
  (set-face-attribute 'flycheck-warning nil
                      :underline '(:style wave :color "#d0bc00"))
  (set-face-attribute 'flycheck-info nil
                      :underline '(:style line :color "#808080")))
(use-package flycheck
  :defer t
  :custom
  (flycheck-highlighting-mode 'symbols)
  (flycheck-indication-mode 'left-fringe)
  (flycheck-display-errors-delay 0.3)
  :config
  (dotfiles-diagnostic-faces))
(use-package lsp-ui
  :commands lsp-ui-mode
  :custom
  (lsp-ui-doc-show-with-cursor nil)
  (lsp-ui-sideline-show-code-actions nil)
  (lsp-ui-sideline-show-diagnostics nil)
  (lsp-ui-sideline-show-hover nil))
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l"
        lsp-completion-provider :capf
        lsp-diagnostics-provider :flycheck
        lsp-enable-snippet t
        lsp-semantic-tokens-enable t
        lsp-enable-on-type-formatting nil
        lsp-disabled-clients '(csharp-roslyn omnisharp csharp-ls))
  :config
  (require 'dotfiles-csharp)
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration))

(require 'csharp-mode)
(defun dotfiles-csharp-disable-document-colors ()
  "Avoid documentColor requests unsupported by Roslyn's C# handler."
  (setq-local lsp-enable-text-document-color nil)
  ;; Also remove the request hook when applying this to an existing buffer.
  (remove-hook 'lsp-on-change-hook #'lsp--document-color t))
(add-hook 'csharp-mode-hook #'dotfiles-csharp-disable-document-colors -90)
(add-hook 'csharp-ts-mode-hook #'dotfiles-csharp-disable-document-colors -90)
(when (treesit-ready-p 'c-sharp t)
  (add-to-list 'major-mode-remap-alist '(csharp-mode . csharp-ts-mode)))
(add-hook 'csharp-mode-hook #'lsp-deferred)
(add-hook 'csharp-ts-mode-hook #'lsp-deferred)
(add-to-list 'auto-mode-alist '("\\.\\(?:csproj\\|props\\|targets\\|slnx\\)\\'" . nxml-mode))
(setq treesit-language-source-alist
      '((c-sharp "https://github.com/tree-sitter/tree-sitter-c-sharp" "v0.23.1")
        (mojo "https://github.com/dmitry-salin/tree-sitter-mojo" "v1.0.5")))

;; Mojo: the mode, its LSP client and build/debug commands load on first use.
(autoload 'mojo-ts-mode "mojo-ts-mode" "Major mode for Mojo." t)
(add-to-list 'auto-mode-alist '("\\.\\(?:mojo\\|🔥\\)\\'" . mojo-ts-mode))
(add-to-list 'interpreter-mode-alist '("mojo" . mojo-ts-mode))
(with-eval-after-load 'mojo-ts-mode (require 'dotfiles-mojo))

(use-package dap-mode
  :commands (dap-debug dap-breakpoint-toggle dap-hydra)
  :config
  (require 'dap-netcore)
  (require 'dap-hydra)
  (dap-auto-configure-mode 1))

(require 'dotfiles-dotnet)
(require 'dotfiles-build)
(load custom-file 'noerror 'nomessage)
