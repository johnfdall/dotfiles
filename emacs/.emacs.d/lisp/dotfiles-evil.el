;;; dotfiles-evil.el --- Neovim-shaped Evil bindings -*- lexical-binding: t; -*-

(require 'evil)
(require 'windmove)

(defvar dotfiles-evil-leader-map (make-sparse-keymap)
  "Commands reached through Space in Evil normal state.")
(evil-define-key 'normal 'global (kbd "SPC") dotfiles-evil-leader-map)

(defun dotfiles-evil-recenter ()
  "Keep the cursor centered after a jump or half-page scroll."
  (recenter))

(evil-define-command dotfiles-evil-scroll-down-centered (count)
  "Scroll down half a window (or COUNT lines), then center the cursor."
  :repeat nil
  (interactive "<c>")
  (evil-scroll-down count)
  (dotfiles-evil-recenter))

(evil-define-command dotfiles-evil-scroll-up-centered (count)
  "Scroll up half a window (or COUNT lines), then center the cursor."
  :repeat nil
  (interactive "<c>")
  (evil-scroll-up count)
  (dotfiles-evil-recenter))

(defun dotfiles-evil-search-next-centered (count)
  (interactive "p")
  (evil-search-next count)
  (dotfiles-evil-recenter))

(defun dotfiles-evil-search-previous-centered (count)
  (interactive "p")
  (evil-search-previous count)
  (dotfiles-evil-recenter))

(defun dotfiles-evil-show-diagnostic ()
  "Show the diagnostic at point, like Neovim's diagnostic float."
  (interactive)
  (if (bound-and-true-p flycheck-mode)
      (flycheck-display-error-at-point)
    (user-error "No live diagnostics are active in this buffer")))

(defun dotfiles-evil-diagnostic-or-focus ()
  "Emulate Neovim's overlapping SPC d and SPC dd/dm/dl mappings.
Emacs keymaps cannot have a key be both a command and a prefix, so wait
briefly for the extra key before showing the diagnostic at point."
  (interactive)
  (pcase (read-event nil nil 0.4)
    (?d (dotfiles-evil-focus-toggle))
    (?m (dotfiles-evil-focus-wider))
    (?l (dotfiles-evil-focus-narrower))
    (event
     (when event
       (setq unread-command-events (cons event unread-command-events)))
     (dotfiles-evil-show-diagnostic))))

(defun dotfiles-evil-show-compilation ()
  "Show the current compilation buffer, if any."
  (interactive)
  (if-let* ((buffer (get-buffer "*compilation*")))
      (pop-to-buffer buffer)
    (user-error "No compilation buffer yet; run SPC m m first")))

(defun dotfiles-evil-close-output-window ()
  "Close the current output window without killing its buffer."
  (interactive)
  (quit-window nil (selected-window)))

(defun dotfiles-evil-focus-toggle ()
  "Toggle a 130-column focused editing view, like NoNeckPain."
  (interactive)
  (olivetti-mode 'toggle))

(defun dotfiles-evil-focus-wider ()
  "Make the focused editing view five columns wider."
  (interactive)
  (setq olivetti-body-width (+ olivetti-body-width 5))
  (when (bound-and-true-p olivetti-mode)
    (olivetti-mode -1) (olivetti-mode 1)))

(defun dotfiles-evil-focus-narrower ()
  "Make the focused editing view five columns narrower."
  (interactive)
  (setq olivetti-body-width (max 40 (- olivetti-body-width 5)))
  (when (bound-and-true-p olivetti-mode)
    (olivetti-mode -1) (olivetti-mode 1)))

;; Match ~/.config/nvim/lua/keymaps.lua.  `SPC' is the normal-mode leader.
(define-key dotfiles-evil-leader-map (kbd "e") #'treemacs)
(define-key dotfiles-evil-leader-map (kbd "p f") #'project-find-file)
(define-key dotfiles-evil-leader-map (kbd "p s") #'consult-ripgrep)
(define-key dotfiles-evil-leader-map (kbd "p b") #'consult-buffer)
(define-key dotfiles-evil-leader-map (kbd "p h") #'consult-info)
(define-key dotfiles-evil-leader-map (kbd "d") #'dotfiles-evil-diagnostic-or-focus)
(define-key dotfiles-evil-leader-map (kbd "m m") #'dotfiles-build)
(define-key dotfiles-evil-leader-map (kbd "m c") #'dotfiles-build-alt)
(define-key dotfiles-evil-leader-map (kbd "m t") #'dotfiles-test)
(define-key dotfiles-evil-leader-map (kbd "m r") #'dotfiles-run)
(define-key dotfiles-evil-leader-map (kbd "m f") #'dotfiles-format)
(define-key dotfiles-evil-leader-map (kbd "c o") #'dotfiles-evil-show-compilation)
(define-key dotfiles-evil-leader-map (kbd "c c") #'dotfiles-evil-close-output-window)
(define-key dotfiles-evil-leader-map (kbd "s v") #'split-window-right)
(define-key dotfiles-evil-leader-map (kbd "s h") #'split-window-below)
(define-key dotfiles-evil-leader-map (kbd "s e") #'balance-windows)
(define-key dotfiles-evil-leader-map (kbd "s x") #'delete-window)

(evil-define-key 'normal 'global (kbd "C-h") #'windmove-left)
(evil-define-key 'normal 'global (kbd "C-j") #'windmove-down)
(evil-define-key 'normal 'global (kbd "C-k") #'windmove-up)
(evil-define-key 'normal 'global (kbd "C-l") #'windmove-right)
(evil-define-key 'normal 'global (kbd "C-\\") #'other-window)
(evil-define-key 'normal 'global (kbd "C-d") #'dotfiles-evil-scroll-down-centered)
(evil-define-key 'normal 'global (kbd "C-u") #'dotfiles-evil-scroll-up-centered)
(evil-define-key 'normal 'global (kbd "n") #'dotfiles-evil-search-next-centered)
(evil-define-key 'normal 'global (kbd "N") #'dotfiles-evil-search-previous-centered)
(evil-define-key 'normal 'global (kbd "g d") #'lsp-find-definition)
(evil-define-key 'normal 'global (kbd "g D") #'lsp-find-declaration)
(evil-define-key 'normal 'global (kbd "g r") #'lsp-find-references)
(evil-define-key 'normal 'global (kbd "K") #'lsp-describe-thing-at-point)
(evil-define-key 'normal 'global (kbd "] q") #'next-error)
(evil-define-key 'normal 'global (kbd "[ q") #'previous-error)
(evil-define-key 'visual 'global (kbd "J") #'move-text-down)
(evil-define-key 'visual 'global (kbd "K") #'move-text-up)

(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    "SPC" "leader"
    "SPC p" "project/picker"
    "SPC m" "build/run"
    "SPC c" "compilation"
    "SPC s" "splits"
    "SPC d" "diagnostic/focus"))

(provide 'dotfiles-evil)
