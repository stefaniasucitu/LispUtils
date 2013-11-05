;http://hyperpolyglot.org/lisp  bobak@balisp.org a few compat fncs, to ease transferring code2cl
(defun nil? (n) (null n))
(defun symbol? (n) (symbolp n))
(defun list? (n) (listp n))
(defun number? (n) (numberp n))
(defun integer? (n) (integerp n))
(defun rational? (n) (rationalp n))
(defun float? (n) (floatp n))
(defun string? (n) (stringp n))
(defun meta (n) (quote n)) ;so (get (meta foo) :prop) -> (get 'foo :prop)
(defconstant false nil)
(defun quot (a b) (truncate a b))
(defun Math/pow (a b) (expt a b))
(defun Math/sqrt (a b) (sqrt a b))
(defun Math/exp (a b) (exp a b))
(defun Math/log (a b) (log a b))
(defun Math/sin (a) (sin a))
(defun Math/cos (a) (cos a))
(defun Math/tan (a) (tan a))
(defun Math/asin (a) (asin a))
(defun Math/acos (a) (acos a))
(defun Math/atan (a) (atan a))
(defun Math/atan2 (a) (atan a))
(defun Math/round (a &optional b) (round a b))
(defun Math/floor (a &optional b) (floor a b))
(defun Math/ceil (a &optional b) (ceiling a b))
(defun bit-shift-left (a b) (ash a b))
;(logbitp j (ash n k)) ==  (and (>= j k) (logbitp (- j k) n))
(defun bit-and (a b) (logand a b))
(defun bit-or (a b) (logior a b))
(defun bit-xor (a b) (logxor a b))
(defun bit-not (a b) (lognot a b))
(defun .charAt (s n) (char s n))
(defun .indexOf (a b) (search b a))
(defun .substring (a b n) (subseq a b n))
(defun .length (a) (length a))
(defun count (a) (length a))
(defgeneric .equals (a b)) ;b-> &rest
(defgeneric .compareTo (a b)) ;b-> &rest
(defmethod .equals ((a String) (b String)) (string= a b))
(defmethod .compareTo ((a String) (b String)) (string< a b))
(defun .toLowerCase (a) (string-downcase a))
(defun str (&rest args)
    ;(reduce #'(lambda (a b) (format nil "~a~a" a b)) args)
    (concatenate 'string args))
(defun Integer/parseInt (a) (parse-integer a))
(defun Float/parseFloat (a) (read-from-string a))
(require :cl-ppcre)
(defun .split (a b) (cl-ppcre:split b a)) ;seq 
(defun .re-seq  (a b) (cl-ppcre:all-matches a b)) 
(defun .replaceAll  (a b) (cl-ppcre:regex-replace-all a b)) 
(defun next (l) (rest l))
(defun concat (a b) (append a b))
;filter remove-if-not
(defun seq (a) (coerce a 'list))
(defun vec (a) (coerce a 'vector))
(defun seq? (a) (typep a 'sequence))
;will also try a cl.clj for fun as well, then look at some past clj code, now incl:
; https://github.com/runa-dev/riemann & https://github.com/andrew-nguyen/titan-clj
; & probably a little program first in cl then clj
