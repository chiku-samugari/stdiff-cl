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

;(stdiff-html '(defun iota (n)
;                (let (lst)
;                  (dotimes (i n (nreverse lst))
;                    (push i lst))))
;             '(defun iota (n &optional (start 0))
;                (let (lst)
;                  (dotimes (i n (nreverse lst))
;                    (push (+ i start) lst))))
;             "iota-diff.html")

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

(with-open-file (out "diff" :direction :output :if-does-not-exist :create :if-exists :supersede)
  (format out "[0m~A"
          (stdiff-terminal
            '(defun iota (n)
               (let (lst)
                 (dotimes (i n (nreverse lst))
                   (push i lst))))
            '(defun iota (n &optional (start 0) (step 1))
               (let (lst)
                 (dotimes (i n (nreverse lst))
                   (push (+ i start) lst))))
            0)))

(defun foo (base modified &optional (allowed-distance 0))
  (let ((table (make-hash-table :test #'equal)))
    (values
      (with-gensyms (refmark lostmark)
        (let ((cl-rainbow:*enabled* t))
          (apply-converters
            (diff base modified refmark lostmark allowed-distance)
            base refmark lostmark
            (lambda (node route codelet)
              (declare (ignorable node route codelet))
              (setf (gethash route table) :new)
              (color :green codelet))
            (lambda (node route codelet)
              (declare (ignorable node route codelet))
              (setf (gethash route table) lostmark)
              (color :red codelet))
            (lambda (node route codelet)
              (declare (ignorable node route codelet))
              (setf (gethash route table) refmark)
              (color :white codelet)))))
      table)))

(with-open-file (out "diff" :direction :output :if-does-not-exist :create :if-exists :supersede)
  (format out "[0m~A"
          (foo
            '(defun iota (n)
               (let (lst)
                 (dotimes (i n (nreverse lst))
                   (push i lst))))
            '(defun iota (n &optional (start 0))
               (let (lst)
                 (dotimes (i n (nreverse lst))
                   (push (+ i start) lst))))
            0)))
