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

(defvar *db* (sqlite:connect "tabbed.db"))
(defvar *tabs* nil)

(defun init-db ()
  (sqlite:execute-non-query *db* "CREATE TABLE IF NOT EXISTS browsers (nid INTEGER PRIMARY KEY, id TEXT NOT NULL, type TEXT NOT NULL, name TEXT NOT NULL)")
  (sqlite:execute-non-query *db* "CREATE TABLE IF NOT EXISTS tabs (id INTEGER PRIMARY KEY, browser_id TEXT NOT NULL, title TEXT NOT NULL, url TEXT NOT NULL, favicon TEXT)"))

;; Print the tabs.
(defun print-tabs ()
  (dolist (tab *tabs*)
	(format t "~{~a:~10t~a~%~}~%" tab)))

;; Define the tab update handler.
(define-easy-handler (update-tabs :uri "/update_tabs"
								  :default-request-type :post) ()
  (let* ((json (decode-json-from-string (raw-post-data
										 :force-text t)))
		 (browser-id (cdr (assoc :id (cdr (assoc :browser json)))))
		 (tabs (cdr (assoc :tabs json))))
	(sqlite:execute-non-query *db* "DELETE FROM tabs WHERE browser_id=?"
							  browser-id)
	(dolist (tab tabs)
	  (sqlite:execute-non-query *db* "INSERT INTO tabs (id, browser_id, title, url, favicon) VALUES (NULL, ?, ?, ?, ?)"
								browser-id
								(cdr (assoc :title tab))
								(cdr (assoc :url tab))
								(cdr (assoc :fav-icon-url tab)))
	  (push (list :title (cdr (assoc :title tab))
				  :url (cdr (assoc :url tab))
				  :favicon (cdr (assoc :fav-icon-url tab)))
			*tabs*))
	(setq *tabs* (reverse *tabs*))
	(print-tabs)
  (format nil "~a~%" (raw-post-data :force-text t))))

;; Setup the error level.
(setf *show-lisp-errors-p* t
	  *show-lisp-backtraces-p* t)

(init-db)

;; Start the Hunchentoot instance.
(start (make-instance 'easy-acceptor :port 8080))

