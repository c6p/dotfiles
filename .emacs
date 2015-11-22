(setq
   backup-by-copying t      ; don't clobber symlinks
   backup-directory-alist
    '(("." . "~/.backup"))    ; don't litter my fs tree
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 2
   version-control t)       ; use versioned backups

(require 'package)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

;; auto-complete
;(add-to-list 'load-path "/usr/share/emacs/site-lisp/auto-complete")
;(require 'auto-complete-config)
;(add-to-list 'ac-dictionary-directories "/usr/share/emacs/site-lisp/auto-complete/ac-dict")
;(ac-config-default)

;; GUI
(set-default-font "Bitstream Vera Sans Mono-8")
(setq default-frame-alist '((font . "Bitstream Vera Sans Mono-8")))
(show-paren-mode 1)
(blink-cursor-mode 0)
(setq inhibit-startup-screen t)
(scroll-bar-mode 0)
(menu-bar-mode 0)
(tool-bar-mode 0)
(blink-cursor-mode 0)
(defalias 'yes-or-no-p 'y-or-n-p)

(setq-default indent-tabs-mode nil) 

;(require 'color-theme)
;(color-theme-initialize)
;(color-theme-classic)

(setq cua-enable-cua-keys nil)
(cua-mode)

;;(require 'org-loaddefs.el)
(setq org-export-html-coding-system 'utf-8-unix)
;; (require 'org-install)
;;(add-to-list 'load-path "/usr/share/emacs/site-lisp/org/org-protocol.elc")
;; (require 'org-protocol)
(setq org-directory "~/data/_org")
(setq org-agenda-files '("~/data/_org/genel.org" "~/data/_org/proje.org" "~/data/_org/olay.org"))
(setq org-archive-location "~/data/_org/arşiv.org::* %s")
(setq org-todo-keywords
    '((sequence "TODO" "|" "DONE")
    (sequence "REPORT" "BUG" "KNOWNCAUSE" "|" "FIXED")
    (sequence "|" "CANCELED")))
(define-key global-map "\C-cc" 'org-capture)
(setq org-capture-templates
      '(("t" "Todo" entry (file "~/data/_org/genel.org")
             "* TODO %?%i\n  %a")
        ("w" "Default template" entry (file+headline "~/data/_org/liste.org" "Web-Mark")
             "* %c\n %u\n %i" :immediate-finish t :kill-buffer t)
        ("g" "Günlük" entry (file+datetree "~/data/_org/günlük.org")
             "* %?%U\n  %i\n  %a")))
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-agenda-custom-commands
'(("c" "Monthly schedule" agenda ""
         (
          (org-agenda-repeating-timestamp-show-all nil)
          (org-agenda-time-grid nil)
          (org-agenda-show-all-dates nil)
          (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
          (org-deadline-warning-days 0)
          )) ))
(setq org-log-done 'note)
 
(add-to-list 'load-path "~/.emacs.d/elisp/")
(load-library "personal")
(load-library "publish")
   

