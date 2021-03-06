;;;; Based a lot on https://github.com/avar/dotemacs/blob/726f0b6cd5badce641be6euf690ca82e9dbdcc605/.emacs

(add-to-list 'load-path "~/.emacs.d/")
(byte-recompile-directory "~/.emacs.d/")

;; font & color
(set-face-attribute
 'default nil
 :font "Bitstream Vera Sans Mono:pixelsize=13:scalable=true:antialias=true")
(require 'color-theme)
(color-theme-initialize)
(add-to-list 'load-path "~/Dev/dist/altercation/solarized/emacs-colors-solarized")
(load "color-theme-solarized")
(color-theme-solarized-light)

;;;; Do we have X? This is false under Debian's emacs-nox package
;;;; where many features are compiled out
(defvar emacs-has-x
  (fboundp 'tool-bar-mode))

;;;; Emacs' interface

(setq initial-buffer-choice "~/.emacs.el")

;; Don't get weird properties when pasting
(setq yank-excluded-properties t)

;; Kill menu, tool and scrollbars with fire!
(when t
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (scroll-bar-mode -1))

;; Bell
(setq ring-bell-function 'ignore)
(setq visible-bell t)

;; Don't ever use graphic dialog boxes
(setq use-dialog-box nil)

;; Don't open new annoying windows under X, use the echo area
(when t
  (tooltip-mode -1))

;; Don't display the 'Welcome to GNU Emacs' buffer on startup
(setq inhibit-startup-message t)

;; Display this instead of "For information about GNU Emacs and the
;; GNU system, type C-h C-a.". This has been made intentionally hard
;; to customize in GNU Emacs so I have to resort to hackery.
(defun display-startup-echo-area-message ()
  (message ""))

;; Don't insert instructions in the *scratch* buffer
(setq initial-scratch-message nil)

;; Display the line and column number in the modeline
(setq line-number-mode t)
(setq column-number-mode t)
(line-number-mode t)
(column-number-mode t)

;; syntax highlight everywhere
(global-font-lock-mode t)

;; Show matching parens
(show-paren-mode t)
(setq show-paren-style 'expression)
(setq show-paren-delay 0.0)

;; Show matching paren, even if off-screen
(defadvice show-paren-function
  (after show-matching-paren-offscreen activate)
  "If the matching paren is offscreen, show the matching line in the
        echo area. Has no effect if the character before point is not of
        the syntax class ')'."
  (interactive)
  (if (not (minibuffer-prompt))
      (let ((matching-text nil))
        ;; Only call `blink-matching-open' if the character before point
        ;; is a close parentheses type character. Otherwise, there's not
        ;; really any point, and `blink-matching-open' would just echo
        ;; "Mismatched parentheses", which gets really annoying.
        (if (char-equal (char-syntax (char-before (point))) ?\))
            (setq matching-text (blink-matching-open)))
        (if (not (null matching-text))
            (message matching-text)))))

(set-face-background 'show-paren-match-face "lavender")

;; Highlight selection
(transient-mark-mode t)

;; make all "yes or no" prompts show "y or n" instead
(fset 'yes-or-no-p 'y-or-n-p)

;; Switching
(iswitchb-mode 1)
(icomplete-mode 1)

;; Smash the training wheels
(put 'narrow-to-region 'disabled nil)
(put 'not-modified 'disabled t)
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'erase-buffer 'disabled nil)
(put 'dired-find-alternate-file 'disabled nil)

;; I use version control, don't annoy me with backup files everywhere
(setq make-backup-files nil)
(setq auto-save-default nil)

;; Make C-h a act as C-u C-h a
(setq apropos-do-all t)

;; For C-u C-x v d. Probably a good idea for everything else too
(setq completion-ignore-case t)

;; Ask me whether to add a final newline to files which don't have one
(setq require-final-newline t)

;;;; User info
(setq user-full-name "Jay McCarthy")
(setq user-mail-address "jay.mccarthy@gmail.com")

;;; Used in ChangeLog entries
(setq add-log-mailing-address user-mail-address)

;;;; Encoding

;; I use UTF-8 for everything on my systems, some of the below might
;; be redundant.
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(setq file-name-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)

;;;; Indenting

;; Use spaces, not tabs
(setq indent-tabs-mode nil)
(setq-default indent-tabs-mode nil)

;; Use 4 spaces
(setq default-tab-width 4)
(setq tab-width 4)

(setq backward-delete-char-untabify nil)

;;;; Mode settings

;;;;; compiling
(setq compilation-scroll-output 'yes)
(setq comint-prompt-read-only t)

;; ANSI colors in command interaction and compile:
(require 'ansi-color)
(defun colorize-compilation-buffer ()
  (toggle-read-only)
  (ansi-color-apply-on-region (point-min) (point-max))
  (toggle-read-only))
(add-hook 'compilation-filter-hook 'colorize-compilation-buffer)

;; Found these in one place
(setq ansi-color-names-vector
      ["black" "#dc322f" "#859900" "#b58900"
       "#268bd2" "#d33682" "#2aa198" "white"])
(ansi-color-map-update 'ansi-color-names-vector ansi-color-names-vector)
;; http://emacsworld.blogspot.com/2009/02/setting-term-mode-colours.html
(setq ansi-term-color-vector
      [unspecified "#000000" "#963F3C" "#859900" "#b58900"
                   "#0082FF" "#FF2180" "#57DCDB" "#FFFFFF"])

;;;;; conf-mode
(add-to-list 'auto-mode-alist '("\\.gitconfig$" . conf-mode))

;;;;; simple.el
(defadvice kill-ring-save (before slickcopy activate compile)
  "When called interactively with no active region, copy
 a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))

(defadvice kill-region (before slickcut activate compile)
  "When called interactively with no active region, kill
 a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))

;;;;; Comint
(setq comint-buffer-maximum-size (expt 2 16))

;;;;; Dired
(add-hook 'dired-mode-hook
          '(lambda ()
             ;; Only open one dired buffer at most
             (define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file)
             ;; Edit files in dired with "e", which previously did what "RET" did
             (define-key dired-mode-map "e" 'wdired-change-to-wdired-mode)))
(setq dired-listing-switches "-alh")

;;;;; emacs-lisp-mode

(add-hook 'emacs-lisp-mode-hook 'eldoc-mode t)

;;;;; eshell-mode

;; Don't display the "Welcome to the Emacs shell" banner
(defun eshell-banner-message "")

;;;;; gdb

;; Turn off the new emacs 22 UI
(setq gdb-many-windows nil)

;;;;; Info-mode

;; scroll to subnodes by default
(setq Info-scroll-prefer-subnodes t)

;;;;; progmodes

;; Settings for progmodes (cperl, c-mode etc.)

(dolist (mode '(c-mode
                java-mode
                html-mode-hook
                css-mode-hook
                emacs-lisp-mode))
  (font-lock-add-keywords mode
                          '(("\\(XXX\\|FIXME\\|TODO\\)"
                             1 font-lock-warning-face prepend))))

;;;;; shell-mode

(add-hook
 'shell-mode-hook
 'ansi-color-for-comint-mode-on)

;;;;; Tramp
(setq tramp-default-method "ssh")

;;;;; vc

;; This could be made portable but I'm not interested in that at the
;; moment so it's git-only.

(defun vc-push-or-pull ()
  "`vc-push' if given an argument, otherwise `vc-pull'"
  (interactive)
  (if current-prefix-arg
      (vc-push)
    (vc-pull)))

(defun vc-push ()
  "Run git-push on the current repository, does a dry-run unless
given a prefix arg."
  (interactive)
  (shell-command "git push"))

(defun vc-pull ()
  "Run git-pull on the current repository."
  (interactive)
  (shell-command "git up"))

;;;;; woman

;; Use woman instead of man
(defalias 'man 'woman)

;;;; Packages

;;;;; start server for emacsclient
(setq server-use-tcp t)
(setq server-host "localhost")
(setq server-name "lightning")

;;(defadvice make-network-process (before force-tcp-server-ipv4 activate)
;;  "Monkey patch the server to force the port"
;;  (if (string= "lightning" (plist-get (ad-get-args 0) :name))
;;      (ad-set-args 0 (plist-put (ad-get-args 0) :service 50000))))

(server-start)

;;;;; line numbering
;;(global-linum-mode 1)

;;(setq linum-disabled-modes-list '(eshell-mode term-mode compilation-mode org-mode))
;;(defun linum-on ()
;;  (unless (or (minibufferp) (member major-mode linum-disabled-modes-list))
;;    (linum-mode 1)))

;;;;; auto-fill
(add-hook 'text-mode-hook 'turn-on-auto-fill)

;;;; multi-term ()
(require 'multi-term)
(setq multi-term-program "/usr/bin/zsh")

;;;;; quack
;;(require 'quack)
(add-to-list 'auto-mode-alist '("\\.rkt$" . scheme-mode))
(add-to-list 'auto-mode-alist '("\\.rktl$" . scheme-mode))
(add-to-list 'auto-mode-alist '("\\.scrbl$" . scheme-mode))
(add-to-list 'auto-mode-alist '("\\.rktd$" . scheme-mode))
(add-to-list 'auto-mode-alist '("\\.ss$" . scheme-mode))
(add-to-list 'auto-mode-alist '("\\.scm$" . scheme-mode))

;;;; Platform specific settings

(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "conkeror")

;;;; global-set-key

(global-set-key (kbd "s-S-t") 'eval-region)
(global-set-key (kbd "s-a") 'mark-whole-buffer)
;;(global-set-key (kbd "s-q") 'kill-emacs)
(global-set-key (kbd "s-c") 'clipboard-kill-ring-save)
(global-set-key (kbd "s-x") 'clipboard-kill-region)
(global-set-key (kbd "s-v") 'clipboard-yank)
(global-set-key (kbd "s-n") 'new-frame)
(global-set-key (kbd "s-s") 'save-buffer)
(global-set-key (kbd "s-f") 'isearch-forward)
(global-set-key (kbd "s-g") 'isearch-repeat-forward)

(defun je/delete-window ()
  "Remove window or frame"
  (interactive)
  (save-current-buffer
    (if (one-window-p 1)
        (delete-frame)
      (delete-window))))
(global-set-key (kbd "s-w") 'je/delete-window)
(global-set-key (kbd "M-w") 'delete-other-windows)

;; Replace the standard way of looking through buffers
(progn
  (global-set-key (kbd "C-x C-b") 'ibuffer))
(define-key global-map (kbd "C-`") 'ibuffer)
(define-key global-map (kbd "M-`") 'iswitchb-buffer)
(define-key global-map (kbd "M-<tab>") 'other-window)

;; ibuffer
(setq ibuffer-use-header-line nil)
(setq directory-abbrev-alist
      '())

(defun je/abbreviate-file-name (name)
  (let ((directory-abbrev-alist
         '(("^/home/jay" . "~")
           ("^/Users/jay" . "~")
           ("^~/Dev/scm" . "~scm")
           ("^~/Dev/dist" . "~dist")
           ("^~dist/sf" . "~sf")
           ("^~sf/full" . "~sff")
           ("^~scm/plt" . "~plt")
           ("^~plt/collects" . "~collects")
           ("^~collects/web-server" . "~ws")
           ("^~scm/github.jeapostrophe" . "~github")
           ("^~github/exp" . "~exp")
           ("^~github/work" . "~work")
           ("^~work/papers" . "~papers")
           ("^~work/courses" . "~courses")
           ("^~github/home" . "~home")
           ("^~home/etc" . "~etc")
           ("^~home/finance" . "~fin")
           ("^~home/journal" . "~j")
           ("^~github/get-bonus" . "~gb")
           ("^~scm/blogs" . "~blogs")
           ("^~blogs/jeapostrophe.github.com/source/downloads/code" . "~je-blog"))))
    (abbreviate-file-name name)))

(setq frame-title-format
      '(:eval (if (buffer-file-name)
                  (je/abbreviate-file-name (buffer-file-name))
                "%b")))

(define-ibuffer-column je/name ()
  (cond
   ((buffer-file-name buffer)
    (je/abbreviate-file-name (buffer-file-name buffer)))
   (t
    (buffer-name buffer))))
(setq ibuffer-formats
      '((mark modified " "
              (je/name 65 65 :left :elide)
              " "
              (mode 16 16 :left :elide))))

;; Setup some font size changers
(define-key global-map (kbd "C-=") 'text-scale-increase)
(define-key global-map (kbd "C--") 'text-scale-decrease)

;; DrRacket-like compiler
(defcustom je/racket-test-p t
  "Whether rkt or rk is run"
  :type 'boolean)
(defun run-current-file (writep)
  "Execute or compile the current file."
  (interactive)
  (let (suffixMap fname suffix progName cmdStr)
    ;; a keyed list of file suffix to comand-line program path/name
    (setq suffixMap
          `(("java" . "javai")
            ("c" . "cci")
            ("sh" . "zsh")
            ("py" . "python")
            ("cc" . "ccci")
            ("cg" . "cgc -noentry")
            ("glsl" . "cgc -noentry -oglsl")
            ("rkt" . ,(if je/racket-test-p "rkt" "rk"))
            ("txt" . "ctxt")
            ("scrbl" . "scribble --pdf")
            ("dot" . "dot -Tpdf -O")
            ("tex" . "pdflatex")))

    (save-buffer)

    (setq fname (buffer-file-name))
    (setq suffix (file-name-extension fname))
    (setq progName (cdr (assoc suffix suffixMap)))
    (setq cmdStr (concat "-i -c \'" progName " \""   fname "\"\'"))

    (if (string-equal suffix "el") ; special case for emacs lisp
        (load-file fname)
      (if progName
          (progn
            (message "Running...")

            (if (and t (file-exists-p (concat default-directory "/Makefile")))
                (compile (concat "zsh -i -c 'cd \"" default-directory "\" && make'"))
              (if (not writep)
                  (compile (concat "zsh " cmdStr))
                (let ((multi-term-program-switches
                       (list "-i" "-c" (concat progName " \"" fname "\""))))
                  (multi-term-dedicated-open)))))
        (progn
          (message "No recognized program file suffix for this file."))))))
(defun run-current-file-ro ()
  "Execute or compile the current file."
  (interactive)
  (run-current-file nil))
(defun run-current-file-wr ()
  "Execute or compile the current file."
  (interactive)
  (run-current-file t))

(global-set-key (kbd "C-t") 'run-current-file-ro)
(global-set-key (kbd "C-M-t") 'run-current-file-wr)

;; A few editing things
(progn
  (global-set-key (kbd "C-c C-i") 'indent-region)
  (global-set-key (kbd "C-c C-c") 'comment-region)
  (global-set-key (kbd "C-c C-v") 'uncomment-region)
  (global-set-key (kbd "C-c q") 'query-replace)
  (global-set-key (kbd "C-c Q") 'query-replace-regexp)
  (global-set-key (kbd "C-c o") 'occur)
  (global-set-key (kbd "C-c d") 'cd)
  (global-set-key (kbd "C-c f") 'find-dired)
  (global-set-key (kbd "C-c g") 'grep))

(defun my-indent-buffer ()
  "Indent the buffer"
  (interactive)

  (save-excursion
    (delete-trailing-whitespace)
    (indent-region (point-min) (point-max) nil)
    (untabify (point-min) (point-max))))

(global-set-key (kbd "s-i") 'my-indent-buffer)

(progn
  (global-set-key (kbd "C-h F") 'find-function-at-point))

;; vc.el - add commands to push and pull with git
(progn
  (define-key vc-prefix-map "p" 'vc-push-or-pull))

;; turn off the ability to kill
(defun custom-cxcc ()
  "Kill the buffer and the frame"
  (interactive)

  (progn
    (kill-buffer)
    (delete-frame)))

(global-set-key (kbd "C-x C-c") 'custom-cxcc)

(global-set-key (kbd "s-r") 'revert-buffer)
(global-set-key (kbd "M-r") 'replace-string)

(global-set-key (kbd "<C-up>") 'beginning-of-buffer)
(global-set-key (kbd "<C-down>") 'end-of-buffer)
(global-set-key (kbd "<C-left>") 'move-beginning-of-line)
(global-set-key (kbd "<C-right>") 'move-end-of-line)

(global-set-key (kbd "<M-left>") 'backward-sexp)
(global-set-key (kbd "<M-right>") 'forward-sexp)

;; For grading
(defun custom-sl ()
  "Submit grade"
  (interactive)

  (progn
    (save-buffer)
    (server-edit)))

(global-set-key (kbd "s-l") 'custom-sl)

(normal-erase-is-backspace-mode 1)

;; Auto saving
(defun je/save-all ()
  "Save all buffers"
  (interactive)
  (desktop-save-in-desktop-dir)
  (save-some-buffers t))

(defvar je/save-timer (run-with-idle-timer 30 t 'je/save-all))
(global-set-key (kbd "s-S") 'je/save-all)

;; Org Mode
(setq load-path (cons "~/Dev/local/org-mode/lisp" load-path))
(setq load-path (cons "~/Dev/local/org-mode/contrib/lisp" load-path))
(add-to-list 'Info-default-directory-list
             (expand-file-name "~/Dev/local/org-mode/doc"))
(require 'org)
(require 'org-faces)
(require 'org-protocol)
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

(setq org-directory "~/Dev/scm/github.jeapostrophe/home/etc/")
(setq org-bookmarks-file "~/Dev/scm/github.jeapostrophe/home/etc/bookmarks.org")
(setq org-default-notes-file "~/Dev/scm/github.jeapostrophe/home/etc/brain.org")
(setq org-agenda-files (list org-directory))

(defun je/org-open-bookmarks ()
  "Open bookmark file"
  (interactive)
  (find-file org-bookmarks-file))
(defun je/org-archive-all ()
  "Archive everything that is done"
  (interactive)
  (org-map-entries 'org-archive-subtree "/DONE" 'file))

(defun je/clear-state-changes ()
  "Clear state changes"
  (interactive)
  (let ((regexp "- State \"DONE\""))
    (let ((buffer-file-name nil)) ;; HACK for `clone-buffer'
      (with-current-buffer (clone-buffer nil nil)
        (let ((inhibit-read-only t))
          (keep-lines regexp)
          (kill-region (line-beginning-position)
                       (point-max)))
        (kill-buffer)))
    (unless (and buffer-read-only kill-read-only-ok)
      ;; Delete lines or make the "Buffer is read-only" error.
      (flush-lines regexp))))

(global-set-key (kbd "s-t")
                (lambda ()
                  (interactive)
                  (if (eq major-mode 'org-mode)
                      (org-todo)
                    (progn
                      (org-agenda-todo)
                      ;; XXX I added this because sometimes it would
                      ;; check the same one twice, but this feels slow
                      ;; and hacky
                      (je/todo-list)))))

(org-defkey org-mode-map [(meta tab)]  nil)

(org-defkey org-mode-map (kbd "s-[") 'org-metaleft)
(org-defkey org-mode-map (kbd "s-]") 'org-metaright)
(org-defkey org-mode-map (kbd "s-{") 'org-shiftleft)
(org-defkey org-mode-map (kbd "s-}") 'org-shiftright)

(defun je/org-meta-return ()
  (interactive)
  (newline)
  (org-meta-return))

(org-defkey org-mode-map [(meta return)]  'je/org-meta-return)
(setq org-M-RET-may-split-line '((default . t)))

(org-defkey org-mode-map [(meta left)]  nil)
(org-defkey org-mode-map [(meta right)] nil)
(org-defkey org-mode-map [(shift meta left)]  nil)
(org-defkey org-mode-map [(shift meta right)] nil)
(org-defkey org-mode-map [(shift up)]          nil)
(org-defkey org-mode-map [(shift down)]        nil)
(org-defkey org-mode-map [(shift left)]        nil)
(org-defkey org-mode-map [(shift right)]       nil)
(org-defkey org-mode-map [(control shift up)]          nil)
(org-defkey org-mode-map [(control shift down)]        nil)
(org-defkey org-mode-map [(control shift left)]        nil)
(org-defkey org-mode-map [(control shift right)]       nil)

(setq org-hide-leading-stars t)
(setq org-return-follows-link t)
(setq org-completion-use-ido t)
(setq org-log-done t)
(setq org-clock-modeline-total 'current)
(setq org-support-shift-select t)
(setq org-agenda-skip-deadline-if-done t)
(setq org-agenda-skip-scheduled-if-done t)
(setq org-agenda-start-on-weekday nil)
(setq org-agenda-include-diary nil)
(setq org-agenda-remove-tags t)
(setq org-agenda-restore-windows-after-quit t)
(setq org-enforce-todo-dependencies t)
(setq org-agenda-dim-blocked-tasks t)
(setq org-agenda-repeating-timestamp-show-all t)
(setq org-agenda-show-all-dates t)
(setq org-timeline-show-empty-dates nil)
(setq org-ctrl-k-protect-subtree t)
(setq org-use-property-inheritance nil)
(setq org-agenda-todo-keyword-format "")

(setq org-todo-keywords
      '((sequence "TODO" "DONE")))

(setq org-time-clocksum-format
      '(:hours "%d" :require-hours t :minutes ":%02d" :require-minutes t))

(setq org-refile-use-outline-path t)
(setq org-outline-path-complete-in-steps t)
(setq org-refile-targets `((nil . (:maxlevel . 20))))
;; This ensures that headings are not refile targets if they do not
;; already have children.
(defun je/has-children ()
  (save-excursion
    (let ((this-level (funcall outline-level)))
      (outline-next-heading)
      (let ((child-level (funcall outline-level)))
        (> child-level this-level)))))
(setq org-refile-target-verify-function 'je/has-children)

(setq org-agenda-todo-ignore-scheduled 'future)
;; Doesn't have an effect in todo mode
;;(setq org-agenda-ndays 365)

;; XXX Make some more for getting %x, %a, and %i
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline org-default-notes-file "Tasks")
         "* TODO %?\n  SCHEDULED: %T\tDEADLINE: %T\n%a")
        ("u" "URL" entry (file+headline org-default-notes-file "Tasks")
         "* TODO %?\n  SCHEDULED: %T\tDEADLINE: %T\n  %a\n %i")
        ("b" "Bookmark" entry (file+headline org-bookmarks-file "To Parse")
         "* %a\n  %i"
         :immediate-finish t)))

(global-set-key
 (kbd "<s-f1>")
 (lambda () (interactive) (org-capture nil "t")))
(global-set-key
 (kbd "<s-XF86MonBrightnessDown>")
 (lambda () (interactive) (org-capture nil "t")))

(setq org-agenda-before-sorting-filter-function 'je/todo-color)
(setq org-agenda-cmp-user-defined 'je/agenda-sort)
(setq org-agenda-sorting-strategy '(user-defined-up))
(setq org-agenda-overriding-columns-format "%56ITEM %DEADLINE")
(setq org-agenda-overriding-header "")

(setq org-agenda-custom-commands
      '(("t" "Todo list" todo "TODO"
         ())))

(add-hook 'org-finalize-agenda-hook
          (lambda ()
            (remove-text-properties
             (point-min) (point-max) '(mouse-face t))))

;;; These are the default colours from OmniFocus
(defface je/due
  (org-compatible-face 'default
    '((t (:foreground "#000000"))))
  "Face for due items"
  :group 'org-faces)
(set-face-foreground 'je/due "#dc322f")

(defface je/today
  (org-compatible-face 'default
    '((t (:foreground "#000000"))))
  "Face for today items"
  :group 'org-faces)
(set-face-foreground 'je/today "#cb4b16")

(defface je/soon
  (org-compatible-face 'default
    '((t (:foreground "#000000"))))
  "Face for soon items"
  :group 'org-faces)
(set-face-foreground 'je/soon "#859900")

(defface je/near
  (org-compatible-face 'default
    '((t (:foreground "#000000"))))
  "Face for near items"
  :group 'org-faces)
(set-face-foreground 'je/near "#6c71c4")

(defface je/normal
  (org-compatible-face 'default
    '((t (:foreground "#000000"))))
  "Face for normal items"
  :group 'org-faces)
(set-face-foreground 'je/normal "#657b83")

(defface je/distant
  (org-compatible-face 'default
    '((t (:foreground "#000000"))))
  "Face for distant items"
  :group 'org-faces)
(set-face-foreground 'je/distant "#93a1a1")

(defvar je-schedule-flag? t)
(setq je-schedule-flag? t)
(defun je/todo-color (a)
  "Color things in the column view differently based on deadline"
  (let* ((ma (or (get-text-property 1 'org-marker a)
                 (get-text-property 1 'org-hd-marker a)))
         (tn (org-float-time (org-current-time)))

         (sa (org-entry-get ma "SCHEDULED"))
         (da (org-entry-get ma "DEADLINE"))

         (ta (if da (org-time-string-to-seconds da) 1.0e+INF))
         (a-day (if da (time-to-days (seconds-to-time ta)) 0))
         (sta (if sa (org-time-string-to-seconds sa) 0)))

    ;; Remove the TODO
    ;; use  (setq org-agenda-todo-keyword-format "") instead?
    (put-text-property
     0 (length a)
     'txt
     (replace-regexp-in-string "^TODO *" "" (get-text-property 0 'txt a))
     a)

    ;; Remove the old face
    (remove-text-properties
     0 (length a) '((face nil) (fontified nil)) a)

    ;; Put on the new face
    (put-text-property
     0 (length a)
     'face
     (cond
      ((< ta tn)
       ;; The deadline has passed
       'je/due)
      ((= a-day (org-today))
       ;; The deadline is today
       'je/today)
      ((< ta (+ tn (* 60 60 24)))
       ;; The deadline is in the next day
       'je/soon)
      ((< ta (+ tn (* 60 60 24 7)))
       ;; The deadline is in the next week
       'je/near)
      ((< ta (+ tn (* 60 60 24 7 4 )))
       ;; The deadline is in the next four weeks
       'je/normal)
      (t
       'je/distant))
     a)

    (if (or (and je-schedule-flag? (< tn sta))
            (and je/org-agenda/filter-ctxt
                 (member/eq je/org-agenda/filter-ctxt
                            (org-entry-get ma "TAGS"))))
        nil
      a)))

(defun member/eq (o l)
  (or (equal o l)
      (member o l)))

(defun je/todo-list ()
  "Open up the org-mode todo list"
  (interactive)

  (progn
    (org-agenda "" "t")
    (org-agenda-columns)))

(defvar je/org-agenda/filter-ctxt nil)

(defun je/todo-list/all ()
  "Open up the org-mode todo list (all)"
  (interactive)
  (progn
    (setq je/org-agenda/filter-ctxt nil)
    (je/todo-list)))
(global-set-key (kbd "s-o") 'je/todo-list/all)

(defun je/todo-list/work ()
  "Open up the org-mode todo list (work)"
  (interactive)
  (progn
    (setq je/org-agenda/filter-ctxt ":Home:")
    (je/todo-list)))
(global-set-key (kbd "s-O") 'je/todo-list/work)

(defun je/todo-list/home ()
  "Open up the org-mode todo list (home)"
  (interactive)
  (progn
    (setq je/org-agenda/filter-ctxt ":Work:")
    (je/todo-list)))
(global-set-key (kbd "s-h") 'je/todo-list/home)

(defun je/agenda-sort (a b)
  "Sorting strategy for agenda items."
  (let* ((ma (or (get-text-property 1 'org-marker a)
                 (get-text-property 1 'org-hd-marker a)))
         (mb (or (get-text-property 1 'org-marker b)
                 (get-text-property 1 'org-hd-marker b)))
         (def 1.0e+INF)
         (da (org-entry-get ma "DEADLINE"))
         (ta (if da (org-time-string-to-seconds da) def))
         (db (org-entry-get mb "DEADLINE"))
         (tb (if db (org-time-string-to-seconds db) def)))
    (cond ((< ta tb) -1)
          ((< tb ta) +1)
          (t nil))))

;; Customized mode line
(setq-default
 mode-line-format
 '((:propertize "%p" face mode-line-folder-face)
   " "
   ;; Position, including warning for 80 columns
   (:propertize "%4l:" face mode-line-position-face)
   (:eval (propertize "%3c" 'face
                      (if (>= (current-column) 80)
                          'mode-line-80col-face
                        'mode-line-position-face)))
   ;; emacsclient [default -- keep?]
   ;;mode-line-client
   ;; read-only or modified status
   " "
   (:eval
    (cond (buffer-read-only
           (propertize " RO " 'face 'mode-line-read-only-face))
          ((buffer-modified-p)
           (propertize " ** " 'face 'mode-line-modified-face))
          (t "      ")))
   " "
   ;; directory and buffer/file name
   ;;(:propertize (:eval (shorten-directory default-directory 5))
   ;;             face mode-line-folder-face)
   (:propertize (:eval (je/abbreviate-file-name (buffer-name)))
                face mode-line-filename-face)
   ;; narrow [default -- keep?]
   ;;" %n "
   ;; mode indicators: vc, recursive edit, major mode, minor modes, process, global
   ;;(vc-mode vc-mode)
   "  %["
   (:propertize mode-name
                face mode-line-mode-face)
   "%] "
   (:eval (propertize (format-mode-line minor-mode-alist)
                      'face 'mode-line-minor-mode-face))
   (:propertize mode-line-process
                face mode-line-process-face)
   (global-mode-string global-mode-string)))

;; Helper function
(defun shorten-directory (dir max-length)
  "Show up to `max-length' characters of a directory name `dir'."
  (let ((path (reverse (split-string (abbreviate-file-name dir) "/")))
        (output ""))
    (when (and path (equal "" (car path)))
      (setq path (cdr path)))
    (while (and path (< (length output) (- max-length 4)))
      (setq output (concat (car path) "/" output))
      (setq path (cdr path)))
    (when path
      (setq output (concat ".../" output)))
    output))

;; Extra mode line faces
(make-face 'mode-line-read-only-face)
(make-face 'mode-line-modified-face)
(make-face 'mode-line-folder-face)
(make-face 'mode-line-filename-face)
(make-face 'mode-line-position-face)
(make-face 'mode-line-mode-face)
(make-face 'mode-line-minor-mode-face)
(make-face 'mode-line-process-face)
(make-face 'mode-line-80col-face)

(defvar light-text "") (setq light-text "#657b83")
(defvar background "") (setq background "#eee8d5")
(defvar light-text-inactive "") (setq light-text-inactive light-text)
(defvar background-inactive "") (setq background-inactive background)
(defvar foreground-warning "") (setq foreground-warning "#dc322f")
(defvar background-warning "") (setq background-warning background)
(defvar bright-text "") (setq bright-text foreground-warning)
(defvar foreground-process "") (setq foreground-process "#dc322f")

(set-face-attribute 'mode-line nil
                    :foreground light-text :background background
                    :inverse-video nil
                    :box `(:line-width 6 :color ,background :style nil))
(set-face-attribute 'mode-line-inactive nil
                    :foreground light-text-inactive :background background-inactive
                    :inverse-video nil
                    :box `(:line-width 6 :color ,background-inactive :style nil))

(set-face-attribute 'mode-line-read-only-face nil
                    :inherit 'mode-line-face
                    :foreground foreground-warning
                    :background background-warning
                    :box `(:line-width 2 :color ,foreground-warning))
(set-face-attribute 'mode-line-modified-face nil
                    :inherit 'mode-line-face
                    :foreground foreground-warning
                    :background background-warning
                    :box `(:line-width 2 :color ,foreground-warning))
(set-face-attribute 'mode-line-folder-face nil
                    :inherit 'mode-line-face
                    :foreground light-text)
(set-face-attribute 'mode-line-filename-face nil
                    :inherit 'mode-line-face
                    :foreground bright-text
                    :weight 'bold)
(set-face-attribute 'mode-line-mode-face nil
                    :inherit 'mode-line-face
                    :foreground light-text-inactive)
(set-face-attribute 'mode-line-minor-mode-face nil
                    :inherit 'mode-line-mode-face
                    :foreground background-inactive
                    :height 110)
(set-face-attribute 'mode-line-process-face nil
                    :inherit 'mode-line-face
                    :foreground foreground-process)
(set-face-attribute 'mode-line-80col-face nil
                    :inherit 'mode-line-position-face
                    :foreground foreground-warning :background background-warning)

;; Desktop
;; save a list of open files in ~/.emacs.desktop
;; save the desktop file automatically if it already exists
(setq desktop-path '("~/.emacs.d/"))
(setq desktop-dirname "~/.emacs.d/")
(setq desktop-base-file-name "emacs-desktop")
(setq desktop-save 'if-exists)
(setq desktop-load-locked-desktop t)

;; save a bunch of variables to the desktop file
;; for lists specify the len of the maximal saved data also
(setq desktop-globals-to-save
      (append '((extended-command-history . 30)
                (file-name-history        . 100)
                (grep-history             . 30)
                (compile-history          . 30)
                (minibuffer-history       . 50)
                (query-replace-history    . 60)
                (read-expression-history  . 60)
                (regexp-history           . 60)
                (regexp-search-ring       . 20)
                (search-ring              . 20)
                (shell-command-history    . 50)
                tags-file-name
                register-alist)))

(desktop-save-mode 1)

;; Broken in switch to Emacs 24
;;(add-to-list 'load-path "~/Dev/dist/nxhtml/util")
;;(require 'winsav)
;;(setq winsav-save t)
;;(setq winsav-dirname "~/.emacs.d/")
;;(winsav-save-mode 1)

;;;;; shift select
(setq shift-select-mode 1)
(delete-selection-mode 1)

;; Auto pair
(add-to-list 'load-path "~/Dev/dist/capitaomorte/autopair")
(require 'autopair)

(add-hook 'scheme-mode-hook 
          #'(lambda () 
              ;; (flymake-mode t)
              (autopair-mode t)))
(add-hook 'emacs-lisp-mode-hook #'(lambda () (autopair-mode t)))

;; CUA
(setq cua-enable-cua-keys nil)           ;; don't add C-x,C-c,C-v
(cua-mode t)                             ;; for rectangles, CUA is nice

(add-hook 'term-mode-hook
          #'(lambda () (setq autopair-dont-activate t)))

(put 'autopair-insert-opening 'delete-selection t)
(put 'autopair-skip-close-maybe 'delete-selection t)
(put 'autopair-insert-or-skip-quote 'delete-selection t)
(put 'autopair-extra-insert-opening 'delete-selection t)
(put 'autopair-extra-skip-close-maybe 'delete-selection t)
(put 'autopair-backspace 'delete-selection 'supersede)
(put 'autopair-newline 'delete-selection t)

;; Rainbow delimiters
(add-to-list 'load-path "~/Dev/local/rainbow-delimiters")
(require 'rainbow-delimiters)
(global-rainbow-delimiters-mode t)

;; Twelf
;;(setq twelf-root "/Users/jay/Dev/dist/Twelf/")
;;(load (concat twelf-root "emacs/twelf-init.el"))

;; dynamic abbreviations
(setq dabbrev-case-fold-search nil)
;; XXX make this play nicer with C++

;; Auto saving
;;(autoload 'paredit-mode "paredit"
;;  "Minor mode for pseudo-structurally editing Lisp code." t)
;;(add-hook 'emacs-lisp-mode-hook       (lambda () (paredit-mode +1)))
;;(add-hook 'lisp-mode-hook             (lambda () (paredit-mode +1)))
;;(add-hook 'lisp-interaction-mode-hook (lambda () (paredit-mode +1)))
;;(add-hook 'scheme-mode-hook           (lambda () (paredit-mode +1)))

;; Insert lambda
(global-set-key (kbd "s-\\")
                (lambda () (interactive nil) (insert "λ")))

;; iBus
(require 'ibus)
(setq ibus-python-shell-command-name
      "python2")
(add-hook 'after-init-hook 'ibus-mode-on)
(setq ibus-cursor-color
      '("red" "blue" "limegreen"))
(add-hook 'after-make-frame-functions
          (lambda (new-frame)
            (select-frame new-frame)
            (or ibus-mode (ibus-mode-on))))
(ibus-define-common-key ?\S-\s nil)
(global-set-key (kbd "M-s-;") 'ibus-toggle)

;; Eli Calc
(autoload 'calculator "calculator"
  "Run the Emacs calculator." t)
(global-set-key [(control return)] 'calculator)

;; W3M
;;(require 'w3m-load)
;;(require 'mime-w3m)

;; v-center
(require 'centered-cursor-mode)
(global-centered-cursor-mode +1)

;; highlight current line (needs to be after v-center)
;; (global-hl-line-mode 1)
;; Doesn't look good with solarized, because there aren't more background colors
;; (set-face-background 'hl-line "#f5f5f5")

;; mark down
(autoload 'markdown-mode "markdown-mode.el"
  "Major mode for editing Markdown files" t)
(setq auto-mode-alist
      (cons '("\\.md" . markdown-mode) auto-mode-alist))

;; spelling
(require 'ispell)
(setq ispell-process-directory (expand-file-name "~/"))
(setq ispell-program-name "aspell")
(setq ispell-list-command "list")
(setq ispell-extra-args '("--sug-mode=ultra"))

(require 'flyspell)
(setq flyspell-issue-message-flag nil)
(dolist (hook '(text-mode-hook latex-mode-hook org-mode-hook markdown-mode-hook))
  (add-hook hook (lambda () (flyspell-mode 1))))
(dolist (hook '(c++-mode-hook elisp-mode-hook))
  (add-hook hook (lambda () (flyspell-prog-mode 1))))
(dolist (hook '(change-log-mode-hook log-edit-mode-hook))
  (add-hook hook (lambda () (flyspell-mode -1))))

;; transparent encryption/decryption
(require 'epa-file)
(epa-file-enable)

;; buffer names
(require 'uniquify)
(setq uniquify-min-dir-content 90
      uniquify-buffer-name-style 'forward)

;; scheme
(load-file "~/.emacs.d/scheme-indent.el")

;; use tex input mode all the time
;;; XXX doesn't work?
(set-input-method "TeX")

;; forth
;;(autoload 'forth-mode "gforth.el")
;;(autoload 'forth-block-mode "gforth.el")
;;(add-to-list 'auto-mode-alist '("\\.fs$" . forth-mode))

;; search is case insensitive
(setq case-fold-search t)
;; XXX I don't know why this works
(setq isearch-mode-hook
      (function (lambda ()
                  (isearch-toggle-case-fold)
                  (isearch-toggle-case-fold))))

;; (require 'flymake)
;; (require 'flymake-cursor)
;; (defun flymake-racket-init ()
;;   (let* ((temp-file (flymake-init-create-temp-buffer-copy
;;                      'flymake-create-temp-inplace))
;;          (local-file (file-relative-name
;;                       temp-file
;;                       (file-name-directory buffer-file-name))))
;;     (list "racket" (list "-qf" local-file))))
;; (setq flymake-gui-warnings-enabled nil)
;; (push '("\\.rkt\\'" flymake-racket-init)
;;       flymake-allowed-file-name-masks)

;; cg mode
(add-to-list 'load-path "~/Dev/local/cg-mode")
(require 'cg-mode)
(add-to-list 'auto-mode-alist '("\\.glsl$" . cg-mode))

;; proof general
(load-file
 "/usr/share/emacs/site-lisp/ProofGeneral/generic/proof-site.el")
;; XXX make these local to the proof mode
;; proof-display-three-b
;; proof-shell-exit
;; proof-process-buffer
;; proof-activate-scripting
(global-set-key (kbd "<M-s-right>") 'proof-goto-point)
(global-set-key (kbd "<M-s-return>") 'proof-goto-point)
(global-set-key (kbd "<M-s-up>") 'proof-undo-last-successful-command)
(global-set-key (kbd "<M-s-down>") 'proof-assert-next-command-interactive)

(setq proof-three-window-mode-policy 'hybrid)
(if nil
    (proof-display-three-b 'hybrid))

;; haskell
(load "/usr/share/emacs/site-lisp/haskell-mode/haskell-mode-autoloads.el")

;;
(defun je/insert-$ (cmd)
  (interactive (list (read-shell-command "$ ")))
  (progn
    (shell-command cmd t)))

(defun sort-words (reverse beg end)
  "Sort words in region alphabetically, in REVERSE if negative.
    Prefixed with negative \\[universal-argument], sorts in reverse.

    The variable `sort-fold-case' determines whether alphabetic case
    affects the sort order.

    See `sort-regexp-fields'."
  (interactive "*P\nr")
  (sort-regexp-fields reverse "[A-Za-z0-9\\.]+" "\\&" beg end))

;; customs

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(doc-view-continuous t)
 '(ibuffer-default-sorting-mode (quote filename/process))
 '(ibuffer-display-summary nil)
 '(safe-local-variable-values (quote ((coq-prog-args "-emacs-U" "-R" ".." "Braun") (coq-prog-args "-emacs-U" "-R" "." "Braun")))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(fringe ((((class color) (background "#fdf6e3")) nil)))
 '(org-column ((t (:background "#fdf6e3" :foreground "#657b83")))))
