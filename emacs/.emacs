;:; packacge --- Summary

(setq package-enable-at-startup nil)
(require 'package)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))
(package-initialize)
(setq use-package-always-ensure t)

(setq inhibit-startup-message t)
(setq lsp-enable-on-type-formatting nil)
(setq lsp-enable-indentation nil)(electric-indent-mode -1)
(cond
 ((eq system-type 'darwin) ; macOS
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'none)) ; or 'super' if you want
 ((eq system-type 'gnu/linux) ; Linux
  (setq x-super-keysym 'meta)
  (setq x-meta-keysym nil)))
(global-display-line-numbers-mode 1)
(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)
(load-theme 'gruvbox-dark-hard t)

(add-hook 'clojure-mode-hook #'lsp)

;; Parinfer Rust Mode for Clojure
(add-hook 'clojure-mode-hook #'parinfer-rust-mode)
(add-hook 'clojurescript-mode-hook #'parinfer-rust-mode)
(add-hook 'clojurec-mode-hook #'parinfer-rust-mode)

;; Rainbow Delimiters
(add-hook 'clojure-mode-hook #'rainbow-delimiters-mode)
(add-hook 'clojurescript-mode-hook #'rainbow-delimiters-mode)
(add-hook 'clojurec-mode-hook #'rainbow-delimiters-mode)

;; clj-refactor
(add-hook 'clojure-mode-hook
          (lambda ()
            (clj-refactor-mode 1)
            (cljr-add-keybindings-with-prefix "C-c C-m")))

(defun my/next-5-lines ()
  "Move curosr down 5 lines."
  (interactive)
  (forward-line 10))

(defun my/previous-5-lines ()
  "Move cursor up 5 lines ."
  (interactive)
  (forward-line -10))

(global-set-key (kbd "M-n") #'my/next-5-lines)
(global-set-key (kbd "M-p") #'my/previous-5-lines)
(global-set-key (kbd "C-x C-b") 'ibuffer)

(use-package exec-path-from-shell
  :ensure t
  :config
  (exec-path-from-shell-initialize))

(use-package expand-region
	    :ensure t
	    :bind ("C-=" . er/expand-region))

(use-package avy
  :ensure t
  :bind (("C-:" . avy-goto-line)
     	 ("C-;" . avy-goto-char-2)))

(use-package centered-cursor-mode
  :ensure t
  :config
  (global-centered-cursor-mode 1))

;; typescript-mode for .ts files
(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . prettier-js-mode))

(use-package olivetti)

;; web-mode for .tsx/.jsx/.js files
(use-package web-mode
  :mode (("\\.tsx\\'" . web-mode)
         ("\\.jsx\\'" . web-mode)
         ("\\.js\\'"  . web-mode))
  :hook ((web-mode . prettier-js-mode)
         (web-mode . emmet-mode)
         (web-mode . (lambda ()
                       (when (string-equal "tsx" (file-name-extension buffer-file-name))
                         (lsp))))))

;; LSP for TypeScript/TSX
(use-package lsp-mode
  :hook ((typescript-mode . lsp)
         (web-mode . (lambda ()
                       (when (string-equal "tsx" (file-name-extension buffer-file-name))
                         (lsp)))))
  :commands lsp
  :config
  (setq lsp-prefer-flymake nil)) ;; Use flycheck instead of flymake

(use-package lsp-ui
  :after lsp-mode
  :commands lsp-ui-mode)

;; Company for autocompletion
(use-package company
  :hook (after-init . global-company-mode))

(with-eval-after-load 'company
  (define-key company-active-map (kbd "C-y") #'company-complete-selection))

(setq company-minimum-prefix-length 1) ;; (default is 3)
(setq company-selection-wrap-around t) ;; (optional: wrap selection)
(setq company-dabbrev-downcase nil)    ;; (optional: preserve case)
(setq company-tooltip-limit 20)        ;; (optional: max candidates shown)
(setq company-auto-complete nil)       ;; <--- disables auto-complete
(setq company-auto-complete-chars nil) ;; <--- disables auto-complete on certain chars

;; Flycheck for linting
(use-package flycheck
  :hook (after-init . global-flycheck-mode))

;; Prettier for formatting
(use-package prettier-js
  :hook ((typescript-mode . prettier-js-mode)
         (web-mode . prettier-js-mode)))

;; Emmet for HTML/CSS snippets
(use-package emmet-mode
  :hook (web-mode . emmet-mode))

;; Yasnippet for snippets (optional)
(use-package yasnippet
  :hook (after-init . yas-global-mode))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("d80952c58cf1b06d936b1392c38230b74ae1a2a6729594770762dc0779ac66b7"
     default))
 '(package-selected-packages
   '(avy centered-cursor-mode cider clj-refactor company emmet-mode
	 exec-path-from-shell expand-region flycheck flymake
	 gruvbox-theme lsp-mode lsp-ui olivetti parinfer-rust-mode
	 prettier-js rainbow-delimiters typescript-mode web-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
