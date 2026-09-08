;;; mojo-ts-mode.el --- Tree-sitter major mode for Mojo -*- lexical-binding: t; -*-

;;; Commentary:

;; Highlighting, imenu and defun navigation use the tree-sitter grammar from
;; https://github.com/dmitry-salin/tree-sitter-mojo; list it as `mojo' in
;; `treesit-language-source-alist' and install it with
;; `treesit-install-language-grammar'.  Indentation reuses python.el's engine:
;; the grammar is Python's with Mojo additions, its scanner emits indent tokens
;; the same way, and python-ts-mode itself does not indent with tree-sitter.
;; The engine's block-opener regexp is compiled into python.el, so the four
;; functions that consult it are advised to also accept Mojo's openers.

;;; Code:

(require 'cl-lib)
(require 'treesit)
(require 'python)

(defgroup mojo-ts-mode nil
  "Editing Mojo with tree-sitter."
  :group 'languages
  :prefix "mojo-ts-mode-")

;;;; Indentation: python.el with Mojo block openers

(defconst mojo-ts-mode--block-start-regexp
  (rx symbol-start
      (or "def" "class" "struct" "trait" "if" "elif" "else" "try" "except"
          "finally" "for" "while" "with" "match" "case" "__extension"
          "__mlir_region"
          (seq (or "async" "comptime") (+ space) (or "def" "for" "with" "if")))
      symbol-end)
  "Statements that open an indented block, including Mojo-only ones.")

(defun mojo-ts-mode--beginning-of-block ()
  "Move to the start of the current block; see `python-nav--beginning-of-block'."
  (let ((starting-pos (point)))
    (while (and (not (bobp))
                (or (and (python-nav-beginning-of-statement) nil)
                    (python-info-current-line-comment-p)
                    (python-info-current-line-empty-p)))
      (forward-line -1))
    (if (progn (python-nav-beginning-of-statement)
               (looking-at mojo-ts-mode--block-start-regexp))
        (point-marker)
      (let ((block-matching-indent
             (- (current-indentation) python-indent-offset)))
        (while (and (python-nav-backward-block)
                    (> (current-indentation) block-matching-indent)))
        (if (and (looking-at mojo-ts-mode--block-start-regexp)
                 (= (current-indentation) block-matching-indent))
            (point-marker)
          (and (goto-char starting-pos) nil))))))

(defun mojo-ts-mode--forward-block (&optional arg)
  "Move forward ARG blocks of code; see `python-nav-forward-block'."
  (or arg (setq arg 1))
  (let ((block-start-regexp
         (concat "^[[:space:]]*" mojo-ts-mode--block-start-regexp))
        (starting-pos (point))
        (orig-arg arg))
    (while (> arg 0)
      (python-nav-end-of-statement)
      (while (and (re-search-forward block-start-regexp nil t)
                  (python-syntax-context-type)))
      (setq arg (1- arg)))
    (while (< arg 0)
      (python-nav-beginning-of-statement)
      (while (and (re-search-backward block-start-regexp nil t)
                  (python-syntax-context-type)))
      (setq arg (1+ arg)))
    (python-nav-beginning-of-statement)
    (if (or (and (> orig-arg 0) (< (point) starting-pos))
            (not (looking-at mojo-ts-mode--block-start-regexp)))
        (and (goto-char starting-pos) nil)
      (and (not (= (point) starting-pos)) (point-marker)))))

(defun mojo-ts-mode--statement-starts-block-p ()
  "Return non-nil if the current statement opens a block."
  (save-excursion
    (python-nav-beginning-of-statement)
    (looking-at mojo-ts-mode--block-start-regexp)))

(defun mojo-ts-mode--dedenter-opening-block-positions ()
  "Positions of the blocks an else/elif/except/finally/case line may close.
Mirrors `python-info-dedenter-opening-block-positions', but also finds
openers such as `comptime if' whose block keyword is not first on the line."
  (save-excursion
    (let ((dedenter-pos (python-info-dedenter-statement-p)))
      (when dedenter-pos
        (goto-char dedenter-pos)
        (let* ((cur-line (line-beginning-position))
               (pairs '(("elif" "elif" "if")
                        ("else" "if" "elif" "except" "for" "while")
                        ("except" "except" "try")
                        ("finally" "else" "except" "try")
                        ("case" "case")))
               (dedenter (match-string-no-properties 0))
               (possible-opening-blocks (cdr (assoc-string dedenter pairs)))
               (collected-indentations)
               (opening-blocks))
          (catch 'exit
            (while (python-nav--syntactically
                    (lambda ()
                      ;; Searching backward reaches the `if' of `comptime if'
                      ;; first, so allow that prefix before the keyword.
                      (cl-loop while (re-search-backward
                                      mojo-ts-mode--block-start-regexp nil t)
                               if (save-match-data
                                    (looking-back
                                     (rx line-start (* whitespace)
                                         (? (or "comptime" "async") (+ space)))
                                     (line-beginning-position)))
                               return t))
                    #'<)
              (let ((indentation (current-indentation))
                    ;; "comptime if" opens the same block as "if".
                    (opener (car (last (split-string
                                        (match-string-no-properties 0))))))
                (when (and (not (memq indentation collected-indentations))
                           (or (not collected-indentations)
                               (< indentation (apply #'min collected-indentations)))
                           (save-excursion
                             (python-nav-end-of-statement)
                             (forward-line)
                             (let ((no-back-indent t))
                               (save-match-data
                                 (while (and (< (point) cur-line)
                                             (setq no-back-indent
                                                   (or (> (current-indentation) indentation)
                                                       (python-info-current-line-empty-p)
                                                       (python-info-current-line-comment-p))))
                                   (forward-line)))
                               no-back-indent)))
                  (push indentation collected-indentations)
                  (when (member opener possible-opening-blocks)
                    (push (point) opening-blocks)))
                (when (zerop indentation)
                  (throw 'exit nil)))))
          (nreverse opening-blocks))))))

(defun mojo-ts-mode--in-mojo (mojo-fn orig-fn &rest args)
  "Call MOJO-FN in Mojo buffers and ORIG-FN with ARGS elsewhere."
  (if (derived-mode-p 'mojo-ts-mode)
      (apply mojo-fn args)
    (apply orig-fn args)))

(advice-add 'python-nav--beginning-of-block :around
            (apply-partially #'mojo-ts-mode--in-mojo
                             #'mojo-ts-mode--beginning-of-block)
            '((name . mojo-ts-mode)))
(advice-add 'python-nav-forward-block :around
            (apply-partially #'mojo-ts-mode--in-mojo
                             #'mojo-ts-mode--forward-block)
            '((name . mojo-ts-mode)))
(advice-add 'python-info-statement-starts-block-p :around
            (apply-partially #'mojo-ts-mode--in-mojo
                             #'mojo-ts-mode--statement-starts-block-p)
            '((name . mojo-ts-mode)))
(advice-add 'python-info-dedenter-opening-block-positions :around
            (apply-partially #'mojo-ts-mode--in-mojo
                             #'mojo-ts-mode--dedenter-opening-block-positions)
            '((name . mojo-ts-mode)))

;;;; Font lock

(defconst mojo-ts-mode--keywords
  '("and" "as" "assert" "async" "await" "break" "class" "comptime" "continue"
    "def" "del" "elif" "else" "except" "finally" "for" "from" "global" "if"
    "import" "in" "is" "is not" "lambda" "nonlocal" "not" "not in" "or" "pass"
    "raise" "ref" "return" "struct" "trait" "try" "var" "while" "with" "yield")
  "Keywords that the grammar exposes as plain tokens.")

(defconst mojo-ts-mode--argument-modifiers
  '("deinit" "imm" "mut" "out" "ref" "var")
  "Argument conventions in parameter lists.")

(defconst mojo-ts-mode--builtin-functions
  '("print" "input" "len" "str" "repr" "abs" "min" "max" "range" "rebind"
    "rebind_var" "debug_assert" "conforms_to" "origin_of" "type_of"
    "bit_width_of" "size_of" "align_of")
  "Functions highlighted as built-ins when called.")

(defconst mojo-ts-mode--builtin-types
  '("SIMD" "Int" "UInt" "Float" "Bool" "String" "StringLiteral" "List"
    "Dict" "Set" "Tuple" "Optional" "Pointer" "UnsafePointer" "Span"
    "DType" "Scalar" "Self")
  "Type names exempt from the all-capitals constant rule.")

(defun mojo-ts-mode--constant-p (node)
  "Return non-nil when identifier NODE looks like a constant."
  (let ((text (treesit-node-text node t)))
    (and (string-match-p "\\`_*[A-Z][A-Z][A-Z0-9_]*\\'" text)
         (not (member text mojo-ts-mode--builtin-types)))))

(defun mojo-ts-mode--fontify-string (node override start end &rest _)
  "Fontify string NODE, treating statement-level strings as docstrings.
OVERRIDE, START and END are as in `treesit-font-lock-rules'."
  (python--treesit-fontify-string node override start end))

(defun mojo-ts-mode--fontify-lhs (node override start end &rest _)
  "Fontify assigned name NODE as a struct field or a variable.
OVERRIDE, START and END are as in `treesit-font-lock-rules'."
  (let* ((block (treesit-parent-until
                 node (lambda (n) (equal (treesit-node-type n) "block"))))
         (owner (and block (treesit-node-type (treesit-node-parent block))))
         (face (if (member owner '("struct_declaration" "trait_declaration"
                                   "extension_declaration"))
                   'font-lock-property-name-face
                 'font-lock-variable-name-face)))
    (treesit-fontify-with-override
     (max start (treesit-node-start node)) (min end (treesit-node-end node))
     face override)))

(defvar mojo-ts-mode--font-lock-settings
  (treesit-font-lock-rules
   :language 'mojo :feature 'comment
   '((comment) @font-lock-comment-face)

   :language 'mojo :feature 'string
   '((string) @mojo-ts-mode--fontify-string
     (mlir_string) @font-lock-string-face)

   :language 'mojo :feature 'string-interpolation :override t
   '((interpolation expression: (identifier) @font-lock-variable-use-face))

   :language 'mojo :feature 'escape-sequence :override t
   '([(escape_sequence) (escape_interpolation)] @font-lock-escape-face)

   :language 'mojo :feature 'keyword
   `([,@mojo-ts-mode--keywords (thin)] @font-lock-keyword-face
     (match_statement "match" @font-lock-keyword-face)
     (case_clause "case" @font-lock-keyword-face)
     (raises "raises" @font-lock-keyword-face)
     (where_clause "where" @font-lock-keyword-face)
     (abi "abi" @font-lock-keyword-face)
     (comptime_statement "type" @font-lock-keyword-face)
     (extension_header "__extension" @font-lock-keyword-face)
     (mlir_region_signature "__mlir_region" @font-lock-keyword-face)
     (callable_parameters [,@mojo-ts-mode--argument-modifiers]
                          @font-lock-keyword-face)
     (function_type_parameters [,@mojo-ts-mode--argument-modifiers]
                               @font-lock-keyword-face)
     (capture_parameter ["imm" "mut" "ref" "var"] @font-lock-keyword-face))

   :language 'mojo :feature 'definition
   '((function_signature name: (identifier) @font-lock-function-name-face)
     (mlir_region_signature name: (identifier) @font-lock-function-name-face)
     (struct_header name: (identifier) @font-lock-type-face)
     (trait_header name: (identifier) @font-lock-type-face)
     (extension_header name: (identifier) @font-lock-type-face)
     (parameter_decl name: (identifier) @font-lock-variable-name-face)
     (default_parameter_decl name: (identifier) @font-lock-variable-name-face)
     (constrained_parameter_decl
      name: (identifier) @font-lock-variable-name-face)
     (variadic_parameter_decl name: (identifier) @font-lock-variable-name-face)
     (constrained_variadic_parameter_decl
      name: (identifier) @font-lock-variable-name-face)
     (constrained_mlir_parameter_decl
      name: (identifier) @font-lock-variable-name-face)
     (lambda_default_parameter_decl
      name: (identifier) @font-lock-variable-name-face)
     (capture_parameter name: (identifier) @font-lock-variable-name-face)
     (comptime_parameter name: (identifier) @font-lock-variable-name-face)
     (constrained_comptime_parameter
      name: (identifier) @font-lock-variable-name-face))

   :language 'mojo :feature 'assignment
   '((assignment left: (identifier) @mojo-ts-mode--fontify-lhs)
     (assignment left: (constrained_lhs (identifier) @mojo-ts-mode--fontify-lhs))
     (augmented_assignment left: (identifier) @font-lock-variable-name-face)
     (comptime_statement
      left: (constrained_comptime_parameter
             name: (identifier) @font-lock-variable-name-face))
     (keyword_argument name: (identifier) @font-lock-variable-name-face))

   :language 'mojo :feature 'type
   '(((identifier) @font-lock-type-face
      (:match "\\`_*[A-Z][A-Za-z0-9_]*\\'" @font-lock-type-face))
     (self) @font-lock-type-face)

   ;; Capitalised compile-time parameters such as T in def f[T: Shape]
   ;; are type variables, not values.
   :language 'mojo :feature 'type :override t
   '(((parameter_declaration (_ name: (identifier) @font-lock-type-face))
      (:match "\\`_*[A-Z][A-Za-z0-9_]*\\'" @font-lock-type-face))
     ((parameters_declaration (_ name: (identifier) @font-lock-type-face))
      (:match "\\`_*[A-Z][A-Za-z0-9_]*\\'" @font-lock-type-face))
     ((comptime_parameter name: (identifier) @font-lock-type-face)
      (:match "\\`_*[A-Z][A-Za-z0-9_]*\\'" @font-lock-type-face))
     ((constrained_comptime_parameter name: (identifier) @font-lock-type-face)
      (:match "\\`_*[A-Z][A-Za-z0-9_]*\\'" @font-lock-type-face)))

   :language 'mojo :feature 'constant :override t
   '(((identifier) @font-lock-constant-face
      (:pred mojo-ts-mode--constant-p @font-lock-constant-face))
     [(true) (false) (none) (ellipsis)] @font-lock-constant-face)

   :language 'mojo :feature 'builtin
   `(((call function: (identifier) @font-lock-builtin-face)
      (:match ,(rx-to-string `(seq bos (or ,@mojo-ts-mode--builtin-functions) eos))
              @font-lock-builtin-face))
     ((identifier) @font-lock-builtin-face
      (:match "\\`self\\'" @font-lock-builtin-face)))

   :language 'mojo :feature 'decorator
   '((decorator "@" @font-lock-preprocessor-face)
     (decorator (identifier) @font-lock-preprocessor-face)
     (decorator (call function: (identifier) @font-lock-preprocessor-face))
     (decorator (member_access member: (identifier) @font-lock-preprocessor-face)))

   :language 'mojo :feature 'number
   '([(integer) (float)] @font-lock-number-face)

   :language 'mojo :feature 'function
   '((call function: (identifier) @font-lock-function-call-face)
     (call function: (subscript value: (identifier) @font-lock-function-call-face))
     (member_call function: (identifier) @font-lock-function-call-face)
     (member_call function: (member_subscript
                             value: (identifier) @font-lock-function-call-face)))

   :language 'mojo :feature 'property
   '((member_access member: (identifier) @font-lock-property-use-face))

   :language 'mojo :feature 'operator
   '(["=" "->" "+" "-" "~" "^" "&" "|" "**" "*" "@" "/" "//" "%" "<<" ">>"
      "==" "!=" "<" "<=" ">" ">=" ":=" "+=" "-=" "*=" "/=" "//=" "%=" "**="
      "@=" "&=" "|=" "^=" "<<=" ">>=" (mlir_operator)]
     @font-lock-operator-face)

   :language 'mojo :feature 'bracket
   '(["(" ")" "[" "]" "{" "}"] @font-lock-bracket-face)

   :language 'mojo :feature 'delimiter
   '(["," "." ":" ";"] @font-lock-delimiter-face)

   :language 'mojo :feature 'variable
   '((identifier) @font-lock-variable-use-face))
  "Tree-sitter font-lock settings for Mojo.")

;;;; Navigation and imenu

(defconst mojo-ts-mode--defun-type-regexp
  (rx bos (or "function_declaration" "struct_declaration" "trait_declaration"
              "extension_declaration" "mlir_region_declaration")
      eos)
  "Node types that count as definitions.")

(defun mojo-ts-mode--defun-name (node)
  "Return the name of the declaration NODE, or nil."
  (when-let* ((header (treesit-search-subtree
                       node
                       (rx bos (or "function_signature" "struct_header"
                                   "trait_header" "extension_header"
                                   "mlir_region_signature")
                           eos)
                       nil nil 1))
              (name (treesit-node-child-by-field-name header "name")))
    (treesit-node-text name t)))

;;;; Mode

;;;###autoload
(define-derived-mode mojo-ts-mode python-base-mode "Mojo"
  "Major mode for editing Mojo, powered by tree-sitter."
  :syntax-table python-mode-syntax-table
  :group 'mojo-ts-mode
  (setq-local python-indent-offset 4
              python-indent-guess-indent-offset-verbose nil
              python-nav-beginning-of-block-regexp
              (concat "^[[:space:]]*" mojo-ts-mode--block-start-regexp)
              syntax-propertize-function python-syntax-propertize-function)
  (when (treesit-ready-p 'mojo)
    (setq treesit-primary-parser (treesit-parser-create 'mojo))
    (setq-local treesit-font-lock-feature-list
                '((comment definition)
                  (keyword string type)
                  (assignment builtin constant decorator escape-sequence
                              number string-interpolation)
                  (bracket delimiter function operator property variable))
                treesit-font-lock-settings mojo-ts-mode--font-lock-settings
                treesit-defun-type-regexp mojo-ts-mode--defun-type-regexp
                treesit-defun-name-function #'mojo-ts-mode--defun-name
                treesit-simple-imenu-settings
                '(("Struct" "\\`struct_declaration\\'" nil nil)
                  ("Trait" "\\`trait_declaration\\'" nil nil)
                  ("Extension" "\\`extension_declaration\\'" nil nil)
                  ("Function" "\\`function_declaration\\'" nil nil)))
    (treesit-major-mode-setup)
    (setq-local syntax-propertize-function #'python--treesit-syntax-propertize))
  (when python-indent-guess-indent-offset
    (python-indent-guess-indent-offset)))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.\\(?:mojo\\|🔥\\)\\'" . mojo-ts-mode))
;;;###autoload
(add-to-list 'interpreter-mode-alist '("mojo" . mojo-ts-mode))

(provide 'mojo-ts-mode)
;;; mojo-ts-mode.el ends here
