;;; poly-sql.el --- Polymode for various programming language with SQL strings  -*- lexical-binding: t; -*-

;; Copyright (C) 2023

;; Author:  <antoine@antoine-AB350-Gaming>
;; Keywords: languages

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'polymode)

(define-hostmode poly-python-hostmode
  :mode 'python-mode)

(define-innermode poly-python-sql-triple-double-quote-innermode
  :mode 'sql-mode
  :head-matcher (cons "[^\\]\\(\"\"\"\\)[[:space:]\r\n]*\\(SELECT\\|WITH\\|INSERT\\|UPDATE\\|DELETE\\|CREATE\\)" 1)
  :tail-matcher (cons "[^\\]\\(\"\"\"\\)" 1)
  :head-mode 'host
  :tail-mode 'host)

(define-innermode poly-python-sql-single-double-quote-innermode
  :mode 'sql-mode
  :head-matcher (cons "[^\\]\\(\"\\)[ \t\f\v]*\\(SELECT\\|WITH\\|INSERT\\|UPDATE\\|DELETE\\|CREATE\\)" 1)
  :tail-matcher (cons "[^\\]\\(\"\\)" 1)
  :head-mode 'host
  :tail-mode 'host)

(define-innermode poly-python-sql-triple-single-quote-innermode
  :mode 'sql-mode
  :head-matcher (cons "[^\\]\\('''\\)[[:space:]\r\n]*\\(SELECT\\|WITH\\|INSERT\\|UPDATE\\|DELETE\\|CREATE\\)" 1)
  :tail-matcher (cons "[^\\]\\('''\\)" 1)
  :head-mode 'host
  :tail-mode 'host)

(define-innermode poly-python-sql-single-single-quote-innermode
  :mode 'sql-mode
  :head-matcher (cons "[^\\]\\('\\)[ \t\f\v]*\\(SELECT\\|WITH\\|INSERT\\|UPDATE\\|DELETE\\|CREATE\\)" 1)
  :tail-matcher (cons "[^\\]\\('\\)" 1)
  :head-mode 'host
  :tail-mode 'host)


(define-polymode poly-python-sql-mode
  :hostmode 'poly-python-hostmode
  :innermodes '(poly-python-sql-triple-double-quote-innermode
                poly-python-sql-single-double-quote-innermode
                poly-python-sql-triple-single-quote-innermode
                poly-python-sql-single-single-quote-innermode))


(when (require 'php nil t)
  (define-hostmode poly-php-hostmode
    :mode 'php-mode)

  (define-innermode poly-php-sql-double-quote-innermode
    :mode 'sql-mode
    :head-matcher (cons "[^\\]\\(\"\\)[[:space:]]*\\(SELECT\\|WITH\\|INSERT\\|UPDATE\\|DELETE\\|CREATE\\)" 1)
    :tail-matcher (cons "[^\\]\\(\"\\)" 1)
    :head-mode 'host
    :tail-mode 'host)

  (define-innermode poly-php-sql-single-quote-innermode
    :mode 'sql-mode
    :head-matcher (cons "[^\\]\\('\\)[[:space:]]*\\(SELECT\\|WITH\\|INSERT\\|UPDATE\\|DELETE\\|CREATE\\)" 1)
    :tail-matcher (cons "[^\\]\\('\\)" 1)
    :head-mode 'host
    :tail-mode 'host)

  (defvar poly-php--heredoc-tag nil)

  (defun poly-php--heredoc-head-match (ahead)
    (let ((matcher "\\(<<<[ \t\f]*\\('\\([[:alpha:]_][[:alpha:]]+\\)'\\|\\([[:alpha:]_][[:alnum:]_]+\\)\\)[ \t\f\v]*[\r]?[\n]\\)[[:space:]]*\\(SELECT\\|WITH\\|INSERT\\|UPDATE\\|DELETE\\|CREATE\\)"))
      (setq poly-php--heredoc-tag nil)
      (if (< ahead 0)
          (when (re-search-backward matcher nil t)
            (setq poly-php--heredoc-tag
                  (or (match-string-no-properties 3)
                      (match-string-no-properties 4)))
              (cons (match-beginning 1) (match-end 1)))
        (when (re-search-forward matcher nil t)
            (setq poly-php--heredoc-tag
                  (or (match-string-no-properties 3)
                      (match-string-no-properties 4)))
            (cons (match-beginning 1) (match-end 1))))))

  (defun poly-php--heredoc-tail-match (ahead)
    (let ((matcher (concat "^[ \t\f]*" poly-php--heredoc-tag "[ \t\f;]*$")))
      (cond
       ((not poly-php--heredoc-tag) nil)
       ((< ahead 0)
        (when (re-search-backward matcher nil t)
          (setq poly-php--heredoc-tag nil)
          (cons (match-beginning 0) (match-end 0))))
       (t (when (re-search-forward matcher nil t)
            (setq poly-php--heredoc-tag nil)
            (cons (match-beginning 0) (match-end 0)))))))

  (define-innermode poly-php-sql-heredoc-innermode
    :mode 'sql-mode
    :head-matcher #'poly-php--heredoc-head-match
    :tail-matcher #'poly-php--heredoc-tail-match
    :head-mode 'host
    :tail-mode 'host)

  (define-polymode poly-php-sql-mode
    :hostmode 'poly-php-hostmode
    :innermodes '(poly-php-sql-double-quote-innermode
                  poly-php-sql-single-quote-innermode
                  poly-php-sql-heredoc-innermode)))

(provide 'poly-sql)
;;; poly-sql.el ends here
