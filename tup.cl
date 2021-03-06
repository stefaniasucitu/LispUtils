;getting some xls/.. into a format for reasoning/learning over, incl joins/conversions/.. ;mike.bobak@gmail
;csv are confidential
;(lu) ;my load-utils, sometimes assumed
;(ql 'cl-unicode) ;these where un-needed when using latest cl-csv from git/vs ql version
;(ql 'cl-rfc2047) (defun decod (s) (cl-rfc2047:decode* s))
;(ql 'babel) ;also has decoders
(defun val=dot-p (c) (equal (cdr c) ".")) ;no value given, so skip
(defun snumstr (s) (if (> (len s) 9) s (numstr s)))
(defun assoc-lists (keys vals)
 ;(mapcar #'cons keys vals)
  (mapcar #'(lambda (k v) (cons k (num-str v))) keys vals)
  )
(defun assoc-col-names (lol)
  (let ((cnames (mapcar #'underscore (first lol))) ;get rid of spaces in colnames
        (vals (rest lol))) ;ListOfLists
   ;(remove-if #'val=dot-p
        (mapcar #'(lambda (vl) (assoc-lists cnames vl)) vals)
   ;)   ;;if I get rid of some keys, then couldn't use some data-table conv routines/but could be ok
    ))
(ql 'cl-csv)
(defun csv2alst (fn) (assoc-col-names (cl-csv:read-csv (make-pathname :name fn))))
;replace 3msg types w/ascii version of all3files in ma.csv ;as type is a col only
;consider libs to read xls &/or open equivalents  ;get csv from each xls sheet
 ;had m-*.csv files(where split from fixed merged file),now back to3original file ma-*.csv
  ;but then have to use latest https://github.com/AccelerationNet/cl-csv vs ql ver or heap prob
(defvar *ma-cc* (csv2alst "ma-cc.csv"))
(defvar *ma-cp* (csv2alst "ma-cp.csv"))
(defvar *ma-pp* (csv2alst "ma-pp.csv"))
(defvar *pd* (csv2alst "pd.csv"))
(defvar *leg* (cl-csv:read-csv (make-pathname :name "pleg.csv"))) ;might use
;when I used parts of a csv lib, I used to turn colname spaces to underscores;do again
;cl-csv has get-data-table-from-csv, &data-table has data-table-to-aslists
(ql 'cl-csv-data-table) (defun alst2dt (lal) (data-table:alists-to-data-table lal))

(defun splural (s) (str-cat s "s"))

(ql 'xml-emitter)
(defun s-tag (pr) (xml-emitter:simple-tag (car pr) (cdr pr)))

;now rework to get the <ens> <en></en>..... </ens> wrapping
(defun xo2 (al en)
  (xml-emitter:with-tag (en)
                   (mapcar #'s-tag al)))
(defun lxo2 (lal &optional (en "msg") (ens (splural en))) 
  (let ((fn (str-cat ens ".xml")))
    (with-open-file (strm fn :direction :output :if-exists :supersede) 
     (let ((*standard-output* strm))
      (xml-emitter:with-xml-output (*standard-output*) 
         (xml-emitter:with-tag (ens)
           (mapcar #'(lambda (x) (xo2 x en)) lal)))))))
;defun tox2 (lal &optional (en "msg") (ens (splural en)))
(defun tox2 ()
  "test output of xml"
  (lxo2 *pd* "person")
  (lxo2 *ma-cc* "msg_cc") 
  (lxo2 *ma-cp* "msg_cp") 
  (lxo2 *ma-pp* "msg_pp") 
  )
 
;could deal w/multibytechars or ignore
;;by using: alias iconv8 'iconv -c -f UTF-8 -t ISO-8859-1 '
;still missed some emojii/etc. Will have to automate/use multibyte-chars
;protege xml-tab can load these w/only a little clean up
;-Did each ppl/msg dump to seperate xml file; might want to split out msgs, otherwise
;  might programatically take convestaion-type slot to split them into subclasses.
;Had msg xls sheets seperate at start, might want to wait for sql or ..;mv on2txt/# analysis

;Started to look@Jambalaya-tab, and realize it would be nice to have inter instance links vs integer-ids
; so can viz not just isa but hasa
;If I could just get the table schema,&load my test data somplace, I could play w/programatically doing it all;still can.
;I did get the schema but have no data in that format; might wait on that; looking at openIE from stanford now too

(defun but-ext (s) (first-str2by-end s #\.))
;USER(1): (len (remove-duplicates (mapcar #'(lambda (x) (but-ext (car x))) (first *pd*)) :test #'equal))
; 62 ;Will also need slot defn of these to have the rest be subslots of
(defvar *clp0* "~%(single-slot ~a~%  (type INTEGER)~%;+    (cardinality 0 1)~% (create-accessor read-write))")
;(mapcar #'(lambda (s0) (format nil *clp0* s0)) (remove-duplicates (mapcar #'(lambda (x) (but-ext (car x))) (first *pd*)) :test #'equal))
;now for clp pont &maybe km, get others slots to be subslots of related
(defun str-ext (s) (last-str2by-end s #\.))
(defvar *clp* "~%(single-slot ~a~%  (type INTEGER)~%;+    (cardinality 0 1)~%;+    (subslot-of ~a)~%   (create-accessor read-write))")
;could alter 1col w/_ instead of ., or deal w/below
(defun print-s-re (s &optional (frmt *clp*) ;(frmt "~%~a -> ~a") 
                                 (strm nil)) 
  (let ((base (but-ext s)))
    (when (and base 
               (len< base s)) ;(format strm frmt base s)
                               (format strm frmt s base)
      )))
(defun slot-hier (lalst) ;list of alsits
  (remove-duplicates
    (mapcar #'(lambda (x) (print-s-re (car x))) (first lalst))
    :test #'equal))
;(slot-hier *pd*) ;not needed for *ma*

;can also try: ;works but in arrays/use if want re ops
;(ql 'cl-simple-table) ;looking at clml mgl etc &nlp..
 ;find ml code that has io for protege frames files
 ;https://github.com/MBcode/malecoli/tree/master/kbs
 ;https://github.com/MBcode/malecoli/tree/master/malecoli/cl-kb
 ;malecoli/mlcl/resources loads algorithm&dataset would be nice
(ql 'mlcl)  ;to read&write the protege-files, and start some machine-leanring work
;cl/kb/io/io.lisp :":"::::::::::"       "   ;3 *.p* files now,will-go2->.pprj&.xml
;(defun kb-import-from-protege-file (pprj-file xml-file &optional (kb *kb*))
;(defun kb-export-to-protege-file (pprj-file xml-file &optional (kb *kb*) (xml-supersedep t) (pprj-supersedep nil))
;io/pprj.lisp ::::::::::::::
;(defvar *empty-pprj-pathname* (find-kb-file "empty"))
;(defun kb-import-from-protege-pprj (pathname kb)
;(defun kb-export-to-protege-pprj (pprj-file xml-file kb &key (supersedep t))
;(defun put-info-into-protege-pprj (pprj xml-file  included-pprj-file-list)
;(defun extract-info-from-protege-pprj (pathname)
;io/xml.lisp ::::::::::::::kb has assoc xml(data/ins&cls info, instead of pins/pont files)
;(defun kb-import-from-protege-xml (pathname kb)
;(defun kb-export-to-protege-xml (pathname kb &key (supersedep t))
;..
;(defun tp () (cl-kb:kb-import-from-protege-file "../up/up.pprj" "")) ;fnc not exported
;Looked at the big dir of pprj/xml files, getting a better sense of them /notes elsewhere

;(defvar *st* (simple-table:read-csv "pd.csv"))

;w/assoc-col-names alists json would be very easy, but old protege frames xmltab is 1st target
;so find simple xml writer that doesn't need fancy format 1st; just an alist
 ;could also just dump alists in pins format, after making a class for a table
;if get use of mysql tables, can use protege Datamaster&skip this(for this part)
;could aslo use one of my db bridges in lisp

;the lisp ML code that can read protege(frames)files,also allows viewing data&running the ML algos on it
 ;algernon-tab ask/tell (via wire) could speed things up ;esp if other lisp code can't do it easily

;lots of cols that are related; might want slot hierarchy (a KM/OWL thing),but also in frames(view)
; nowadays I might skip protege if I could just get a good KM gui; (power)LOOM also possible
 ;might be an excuse to use DL in old or newer version of protege &the new tabs, incl spreadsheet import

;some slots end in #w for which week meansured, instead of further branch in slot heirarchy, could array/multislot but
; the week measures are not all the same so would need an alist or a multislot of measure instances, that have the date-time

;utils.clp has a km-tax that might dump for KM; but also want reorg for ML algorithms, ;might look at data-table/cl-ana etc too
 ;subslots that partition by time might be workable, would be nice to have multislot view at higher level, but regular/fitted ;sparklines

;Other than viz off of R-stat/studio &re-viz/explore(ipy/juypyter/etc),I might use xlispstat's vista, as imput is similar to arff files*
 ;*which that ML code has IO for,  (as well as many envs incl weka/...)

;having a sharable data-table would be nice, maybe even pass via(feather when more in use),though arff,etc ok now too

;end goal somewhat similar to:
;"Natural Language Processing for Mental Health: Large Scale Discourse Analysis of Counseling Conversations": arxiv.org/abs/1605.04462
;How do you make someone feel better? NLP to promote #mentalhealth. See TACL paper at http://stanford.io/1XrwOjL . With @jure & @stanfordnlp
;http://nlp.stanford.edu/blog/how-to-help-someone-feel-better-nlp-for-mental-health/ has: http://snap.stanford.edu/counseling/
;http://wiki.knoesis.org/index.php/Modeling_Social_Behavior_for_Healthcare_Utilization_in_Depression
