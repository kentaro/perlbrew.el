;;; perlbrew.el --- A perlbrew wrapper for Emacs

;; Copyright (C) 2011 Kentaro Kuribayashi

;; Author: Kentaro Kuribayashi <kentarok@gmail.com>
;; Keywords: Emacs, Perl

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; (require 'perlbrew)
;; (perlbrew-use "perl-5.12.3") ;; initialize perl version to use

;;; Code:

(defvar perlbrew-dir (concat (getenv "HOME") "/perl5/perlbrew"))
(defvar perlbrew-perls-dir (concat perlbrew-dir "/perls"))
(defvar perlbrew-command-path (concat perlbrew-dir "/bin/perlbrew"))

(defvar perlbrew-current-perl-dir nil)
(defvar perlbrew-current-perl-path nil)

(eval-when-compile
  (require 'cl))

(defun perlbrew (args)
  (interactive "M$ perlbrew ")
  (let* ((command (perlbrew-command args))
         (result (perlbrew-trim (shell-command-to-string command))))
    (if (called-interactively-p 'interactive)
        (unless (string-match "^\\s*$" result) (message result))
      result)))

(defun perlbrew-use (version)
  (interactive (list (completing-read "Version: " (perlbrew-list))))
  (perlbrew-set-current-perl-path version)
  (perlbrew-set-current-exec-path))

(defun perlbrew-switch (version)
  (interactive (list (completing-read "Version: " (perlbrew-list))))
  (perlbrew-use version))

(defun perlbrew-command (args)
  (perlbrew-join (list perlbrew-command-path args)))

(defun perlbrew-list ()
  (let* ((perls (split-string (perlbrew "list"))))
    (remove-if
     (lambda (i)
       (not (string-match "^\\(perl\\|[0-9]\\|system\\)" i)))
     (append perls '("system")))))

(defun perlbrew-get-current-perl-path ()
  perlbrew-current-perl-path)

(defun perlbrew-set-current-perl-path (version)
  (setq perlbrew-current-perl-dir (concat perlbrew-perls-dir "/" version))
  (setq perlbrew-current-perl-path (concat perlbrew-current-perl-dir "/bin/perl")))

(defun perlbrew-set-current-exec-path ()
  (let ((bin-dir (concat perlbrew-current-perl-dir "/bin")))
    ;; setting for PATH
    (setenv "PATH" (concat bin-dir ":" (getenv "PATH")))

    ;; setting for exec-path
    (delete bin-dir exec-path)
    (add-to-list 'exec-path bin-dir)
    ))

(defun perlbrew-join (list)
  (mapconcat 'identity list " "))

(defun perlbrew-trim (string)
  (replace-regexp-in-string "\n+$" "" string))

(provide 'perlbrew)
;;; perlbrew.el ends here
