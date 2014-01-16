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

(defun stdiff-terminal (base modified &optional (allowed-distance 0))
  (let ((cl-rainbow:*enabled* t))
    (pair-coloring
      "({" "})" #'(color :green)
      (pair-coloring
        "([" "])" #'(color :red) (bracebracket base modified allowed-distance)))))

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
