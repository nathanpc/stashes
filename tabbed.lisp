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

(defun init-db ()
  (sqlite:execute-non-query *db* "CREATE TABLE IF NOT EXISTS browsers (nid INTEGER PRIMARY KEY, id TEXT NOT NULL, type TEXT NOT NULL, name TEXT NOT NULL)")
  (sqlite:execute-non-query *db* "CREATE TABLE IF NOT EXISTS tabs (id INTEGER PRIMARY KEY, browser_id TEXT NOT NULL, title TEXT NOT NULL, url TEXT NOT NULL, favicon TEXT)"))

(define-easy-handler (update-browser :uri "/update_browser"
									 :default-request-type :post) ()
  (let* ((json (decode-json-from-string (raw-post-data
										 :force-text t)))
		 (browser (cdr (assoc :browser json))))
	(sqlite:execute-non-query *db* "DELETE FROM browsers WHERE id=?"
							  (cdr (assoc :id browser)))
	(sqlite:execute-non-query *db* "INSERT INTO browsers (nid, id, type, name) VALUES (NULL, ?, ?, ?)"
							  (cdr (assoc :id browser))
							  (cdr (assoc :type browser))
							  (cdr (assoc :name browser)))
	(format nil "Done.")))

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
								(cdr (assoc :fav-icon-url tab))))
  (format nil "~a~%" (raw-post-data :force-text t))))

;; Tabs list handler.
(define-easy-handler (list-tabs :uri "/list"
								:default-request-type :get) ()
  (let* ((json (make-hash-table))
		 (browsers nil)
		 (tabs nil)
		 (tab-hash (make-hash-table))
		 (browser-hash (make-hash-table)))
	(dolist (browser (sqlite:execute-to-list *db* "SELECT id, type, name FROM browsers"))
	  (setf browser-hash (make-hash-table))
	  (setf (gethash 'id browser-hash) (nth 0 browser))
	  (setf (gethash 'type browser-hash) (nth 1 browser))
	  (setf (gethash 'name browser-hash) (nth 2 browser))
	  (push browser-hash browsers))
	(dolist (tab (sqlite:execute-to-list *db* "SELECT browser_id, title, url, favicon FROM tabs"))
	  (setf tab-hash (make-hash-table))
	  (setf (gethash 'browser_id tab-hash) (nth 0 tab))
	  (setf (gethash 'title tab-hash) (nth 1 tab))
	  (setf (gethash 'url tab-hash) (nth 2 tab))
	  (setf (gethash 'favicon tab-hash) (nth 3 tab))
	  (push tab-hash tabs))
	(setq tabs (reverse tabs))
	(setf (gethash 'browsers json) browsers)
	(setf (gethash 'tabs json) tabs)
	(encode-json-to-string json)))

;; Setup the error level.
(setf *show-lisp-errors-p* t
	  *show-lisp-backtraces-p* t)

;; Start the Hunchentoot instance.
(init-db)
(start (make-instance 'easy-acceptor :port 8080
					  :document-root #p"static/"))

