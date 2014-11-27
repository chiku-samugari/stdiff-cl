(in-package :cl-user)

(require :cl-rainbow)

(require :pphtml)

(defpackage :stdiff-cl
  (:use :cl :chiku.util :papply :stdiff :pphtml :cl-rainbow)
  (:shadowing-import-from :cl-rainbow :color)
  (:export :stdiff-html :stdiff-terminal))
