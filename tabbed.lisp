;;; Tabbed
;;; A simple service to access tabs from other browsers.
;;;
;;; Nathan Campos <nathanpc@dreamintech.net>

(ql:quickload :hunchentoot)
(ql:quickload :cl-json)
(ql:quickload :sqlite)

(defpackage :tabbed
  (:use :cl :hunchentoot :json))
(in-package :tabbed)

(setf *show-lisp-errors-p* t
	  *show-lisp-backtraces-p* t)

(defvar *tabs* nil)

(defun print-tabs ()
  (dolist (tab *tabs*)
	(format t "~{~a:~10t~a~%~}~%" tab)))

(define-easy-handler (update-tabs :uri "/update_tabs"
								  :default-request-type :post) ()
  (let* ((json (decode-json-from-string (raw-post-data
										 :force-text t)))
		 (tabs (cdr (assoc :tabs json))))
	(dolist (tab tabs)
	  (push (list :title (cdr (assoc :title tab))
				  :url (cdr (assoc :url tab))
				  :favicon (cdr (assoc :fav-icon-url tab)))
			*tabs*))
	(setq *tabs* (reverse *tabs*))
	(print-tabs)
  (format nil "~a~%" (raw-post-data :force-text t))))

(start (make-instance 'easy-acceptor :port 8080))

