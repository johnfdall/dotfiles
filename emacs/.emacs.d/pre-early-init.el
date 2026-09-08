;;; pre-early-init.el --- Personal defaults -*- no-byte-compile: t; lexical-binding: t; -*-
(setq minimal-emacs-ui-features '(context-menu tooltips))
(setq user-emacs-directory (expand-file-name "~/.emacs.d/var/")
      package-user-dir (expand-file-name "elpa/" user-emacs-directory))
(make-directory user-emacs-directory t)
(setq ns-command-modifier 'meta
      ns-option-modifier 'none
      mac-command-modifier 'meta
      mac-option-modifier 'none)
(add-to-list 'default-frame-alist '(font . "JetBrains Mono-14"))
(add-to-list 'default-frame-alist '(width . 120))
(add-to-list 'default-frame-alist '(height . 45))
(add-to-list 'default-frame-alist '(undecorated . t))
