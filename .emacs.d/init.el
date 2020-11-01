(load "/home/euphemia/.emacs.d/el-get/benchmark-init/benchmark-init.el"
      'no-error nil 'no-suffix)

; invoke el-get
(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

(add-to-list 'el-get-recipe-path "~/.emacs.d/el-get-user/recipes")
(el-get 'sync)

(setq
 my:el-get-packages
 '(el-get
    company-mode
    color-theme
    color-theme-zenburn
    airline-themes
    benchmark-init
    cl-lib
    company-c-headers
    company-irony
    company-mode
    dash 
    el-get
    epl
    flycheck
    flycheck-irony
    hl-line+
    irony-eldoc
    irony-mode
    js2-mode
    js2-refactor
    let-alist
    markdown-mode
    mocha
    monokai-theme
    multiple-cursors
    nyan-mode
    org-mode
    package
    pkg-info
    powerline
    s
    seq
    simpleclip
    smooth-scroll
    solidity-mode
    use-package
    xref-js2))

(setq my:el-get-packages
      (append my:el-get-packages
              (mapcar #'el-get-source-name el-get-sources)))

;; install new packages and init already installed packages
(el-get 'sync my:el-get-packages)

(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))

(add-hook 'after-init-hook 'global-company-mode)
(add-hook 'after-init-hook (lambda () (load-theme 'monokai t)))
(add-hook 'after-init-hook 'nyan-mode)


;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(if (not (package-installed-p 'use-package))
    (progn
      (package-refresh-contents)
      (package-install 'use-package)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("3eb93cd9a0da0f3e86b5d932ac0e3b5f0f50de7a0b805d4eb1f67782e9eb67a4" default)))
 '(indent-tabs-mode nil)
 '(package-selected-packages
   (quote
    (monokai-theme dracula-theme org-link-minor-mode zenburn-theme seq let-alist))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(minibuffer-prompt ((t (:background "#dfff00" :foreground "#202020" :box nil))))
 '(mode-line-buffer-id ((t (:background "#dfff00" :foreground "#202020" :box nil :overline nil :underline nil :weight bold))))
 '(whitespace-tab ((t (:background "red")))))

; Highlight tabs and trailing whitespace everywhere
(setq whitespace-style '(face trailing tabs))

(global-whitespace-mode)

(require 'use-package)
(use-package xclip
  :ensure t)
(require 'xclip)
(xclip-mode 1)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default c-basic-offset 4)

(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
(add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode)
(add-hook 'ielm-mode-hook 'turn-on-eldoc-mode)

;; =============
;; irony-mode
;; =============

(defun my-irony-mode-on ()
  ;; avoid enabling irony-mode in modes that inherits c-mode, e.g: php-mode
  (when (member major-mode irony-supported-major-modes)
    (irony-mode 1)))

(add-hook 'c++-mode-hook 'my-irony-mode-on)
(add-hook 'c-mode-hook 'my-irony-mode-on)
;; =============
;; company mode
;; =============
(add-hook 'c++-mode-hook 'company-mode)
(add-hook 'c-mode-hook 'company-mode)
;; replace the `completion-at-point' and `complete-symbol' bindings in
;; irony-mode's buffers by irony-mode's function
(defun my-irony-mode-hook ()
  (define-key irony-mode-map [remap completion-at-point]
    'irony-completion-at-point-async)
  (define-key irony-mode-map [remap complete-symbol]
    'irony-completion-at-point-async))
(add-hook 'irony-mode-hook 'my-irony-mode-hook)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
(eval-after-load 'company
  '(add-to-list 'company-backends 'company-irony))
;; (optional) adds CC special commands to `company-begin-commands' in order to
;; trigger completion at interesting places, such as after scope operator
;;     std::|
(add-hook 'irony-mode-hook 'company-irony-setup-begin-commands)
;; =============
;; flycheck-mode
;; =============
(add-hook 'c++-mode-hook 'flycheck-mode)
(add-hook 'c-mode-hook 'flycheck-mode)
(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-irony-setup))
;; =============
;; eldoc-mode
;; =============
(add-hook 'irony-mode-hook 'irony-eldoc)
;; ==========================================
;; (optional) bind TAB for indent-or-complete
;; ==========================================
(defun irony--check-expansion ()
  (save-excursion
    (if (looking-at "\\_>") t
      (backward-char 1)
      (if (looking-at "\\.") t
        (backward-char 1)
        (if (looking-at "->") t nil)))))
(defun irony--indent-or-complete ()
  "Indent or Complete"
  (interactive)
  (cond ((and (not (use-region-p))
              (irony--check-expansion))
         (message "complete")
         (company-complete-common))
        (t
         (message "indent")
         (call-interactively 'c-indent-line-or-region))))
(defun irony-mode-keys ()
  "Modify keymaps used by `irony-mode'."
  (local-set-key (kbd "TAB") 'irony--indent-or-complete)
  (local-set-key [tab] 'irony--indent-or-complete))
(add-hook 'c-mode-common-hook 'irony-mode-keys)
     ```
(setq indent-tabs-mode nil)


(require 'powerline)
(powerline-default-theme)
(require 'airline-themes)
;(load-theme 'airline-ubaryd)
(load-theme 'airline-dark)
;(load-theme 'airline-molokai)
;(custom-theme-set-faces
; 'airline-dark
; `(minibuffer-prompt ((t (:background "#444444" :foreground "#444444" :weight bold))))
; `(minibuffer-prompt ((t (:foreground "#444444" :background "#dfff00" ))))
;)

(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time   
(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse
(setq scroll-step 1) ;; keyboard scroll one line at a time




(use-package irony
  :hook (((c++-mode c-mode objc-mode) . irony-mode-on-maybe)
         (irony-mode . irony-cdb-autosetup-compile-options))
  :config
  (defun irony-mode-on-maybe ()
    ;; avoid enabling irony-mode in modes that inherits c-mode, e.g: solidity-mode
    (when (member major-mode irony-supported-major-modes)
      (irony-mode 1))))
(setq inhibit-startup-screen t)
(setq initial-scratch-message "")
(setq initial-major-mode 'text-mode)
