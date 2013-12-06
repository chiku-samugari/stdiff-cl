(defpackage :stdiff-cl.asd
  (:use :cl :asdf))

(in-package :stdiff-cl.asd)

(defsystem :stdiff-cl
  :version "0.2.0"
  :maintainer "Takehiko Nawata"
  :author "Takehiko Nawata"
  :license "MIT License"
  :description "STDIFF Common Lisp"
  :long-description "Show STDIFF of Common Lisp code."
  :serial t
  :components ((:file "packages")
               (:file "stdiff-cl"))
  :defsystem-depends-on (:pphtml :stdiff))
