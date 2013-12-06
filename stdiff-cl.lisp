(in-package :stdiff-cl)

(defun wrap-by-bracket (expr)
  (list '[ expr ']))

(defun wrap-by-brace (expr)
  (list '{ expr '}))

(defun bracebracket (base modified &optional (allowed-distance 0))
  (with-gensyms (refmark lostmark)
    (apply-modifiednode-converters
      (diff base modified refmark lostmark allowed-distance)
      base refmark lostmark #'wrap-by-brace #'wrap-by-bracket)))

(defun stdiff-html (base modified outhtml-pathspec &optional (allowed-distance 0))
  (output-as-html (format nil "<pre>~a</pre>"
                          (pair-coloring
                            "({" "})" #'green
                            (pair-coloring
                              "([" "])" #'red (bracebracket base modified allowed-distance))))
                  outhtml-pathspec))

;(stdiff-html '(defun iota (n)
;                (let (lst)
;                  (dotimes (i n (nreverse lst))
;                    (push i lst))))
;             '(defun iota (n &optional (start 0))
;                (let (lst)
;                  (dotimes (i n (nreverse lst))
;                    (push (+ i start) lst))))
;             "iota-diff.html")
