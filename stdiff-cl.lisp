(in-package :stdiff-cl)

(defun wrap-by-bracket (expr)
  (list '[ expr ']))

(defun wrap-by-brace (expr)
  (list '{ expr '}))

(defun wrap-by-triangle (expr)
  (list '< expr '>))

(defun bracebracket (base modified &optional (allowed-distance 0))
  (multiple-value-bind (reftree losttree new ref lost cited)
    (diff base modified allowed-distance)
    (apply-easy-converters
      base modified reftree losttree new ref lost cited
      #'wrap-by-brace #'identity #'wrap-by-bracket #'wrap-by-triangle)))

(defun stdiff-html (base modified outhtml-pathspec &optional (allowed-distance 0))
  (multiple-value-call
    #'(output-as-html (format nil "<pre>~a</pre><br/><br/><pre>~A</pre>"
                              (pair-coloring  "(<" ">)" #'yellow (pair-coloring "([" "])" #'red a1))
                              (pair-coloring "({" "})" #'green a0))
                      outhtml-pathspec)
    (bracebracket base modified allowed-distance)))


(defun stdiff-terminal (base modified &optional (allowed-distance 0))
  (let ((cl-rainbow:*enabled* t))
    (multiple-value-bind (refside lostside)
      (bracebracket base modified allowed-distance)
      (values
        (pair-coloring
          "(<" ">)" #'(cl-rainbow:color :yellow)
          (pair-coloring
            "([" "])" #'(cl-rainbow:color :red) lostside))
        (pair-coloring
          "({" "})" #'(cl-rainbow:color :green) refside)
        ))))
