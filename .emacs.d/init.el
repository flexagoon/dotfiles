;; UI Tweaks
(scroll-bar-mode 0)
(tool-bar-mode 0)
(menu-bar-mode 0)
(tooltip-mode 0)

(set-fringe-mode 10)

;; Font
(set-face-attribute 'default nil :font "Fira Code")

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Package manager
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(require 'use-package)
(setq use-package-always-ensure t)

;; Completion
(use-package ivy
  :bind (:map ivy-minibuffer-map
	      ("C-l" . ivy-alt-done)
	      ("C-j" . ivy-next-line)
	      ("C-k" . ivy-previous-line))
  :init (ivy-mode 1))

(use-package company
  :init (global-company-mode 1))

(require 'color)
  
(let ((bg (face-attribute 'default :background)))
  (custom-set-faces
   `(company-tooltip ((t (:inherit default :background ,(color-lighten-name bg 2)))))
   `(company-scrollbar-bg ((t (:background ,(color-lighten-name bg 10)))))
   `(company-scrollbar-fg ((t (:background ,(color-lighten-name bg 5)))))
   `(company-tooltip-selection ((t (:inherit font-lock-function-name-face))))
   `(company-tooltip-common ((t (:inherit font-lock-constant-face))))))

;; Doom Modeline
(use-package doom-modeline :init (doom-modeline-mode 1))

;; Line Numbers
(column-number-mode)
(global-display-line-numbers-mode t)

(dolist (mode '(org-mode-hook
		shell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Rainbow Delimiters
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Which-key
(use-package which-key
  :init (which-key-mode)
  :config
  (setq which-key-idle-delay 0.3))

;; Theme
(use-package doom-themes
  :config
  (load-theme 'doom-nord t))

;; Dashboard
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner 'logo))

;; Keybinds
(use-package evil
  :init (evil-mode 1))

(use-package evil-leader
  :ensure t
  :defer t
  :config
  (global-evil-leader-mode)
  (evil-leader/set-leader "<SPC>"))

(evil-leader/set-key
  ":" 'counsel-M-x
  "." 'find-file
  "h" 'help-command
  "b" 'counsel-switch-buffer
  "e" 'eval-last-sexp

  ;; File management
  "fs" 'save-buffer
)

;; Org

;;(defun fg/org-mode-setup ()
;;  (org-indent-mode))
  

(use-package org
  ;;:hook (org-mode . fg/org-mode-setup)
  :config
  (setq org-ellipsis " ▾"
	org-hide-emphasis-markers t))

(use-package org-superstar
  :after org
  :hook (org-mode . org-superstar-mode))
