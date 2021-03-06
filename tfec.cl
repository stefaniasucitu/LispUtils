;Hack Night at Heroku, neo4j example, in Lisp, bobak@computer.org
;http://www.meetup.com/Data-Mining/events/80275492/t/cr1_grp/?rv=cr1 went over:
; https://github.com/akollegger/FEC_GRAPH &I coudn't get2boxIcompiled on, so rewrote
; Also wanted an excuse to try cl-neo4j, and compare w/say:allegrograph,vivace-graph-v2..&even KM
; so not only test of basic utils, but of the km utils as well.
; (load "util_mb") (load "km_2-5-33") (load "u2")or(load "utkm");w/sv-al edit
;-was c2h.cl
(defvar *c2h* '(
 ("aic" (CONTRIBKEY commID contribDate contribSearchDate contribAmt CONTRIBTYPE CONTRIBID))
 ("can" (candidateID candidateNAME name candidatePARTY candidateELECTIONYEAR candidateOFFICESTATE candidateOFFICE candidateDISTRICT candidateICI candidateSTATUS candidatePCC candidateST1 candidateST2 candidateMAILCITY candidateMAILST candidateMAILPOSTAL))
 ("com" (commID commNAME name commTREAS commADDR1 commADDR2 commCITY commSTATE commZIP commDSG commTYPE commPARTYAFFIL commFILING))
 ;swap 1st 2, or at least set 2nd as i: {$2 $1 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14}
 ("spd" (RECEIPT_TYPE SUPER_PAC SUPER_PAC_ID DONATING_ORG DONOR_LAST DONOR_FIRST DONOR_CITY DONOR_STATE DONOR_OCCUPATION DONOR_EMPLOYER DONOR_AMOUNT DONATION_DATE TOTAL_AMT TRANS_ID)) ;lines w/^M
 ("spe" (SPENDING_COMM SPENDING_COMM_ID SUPERPAC ELECTION_TYPE CANDIDATE SUPPORT_OPPOSE CANDIDATE_ID CANDIDATE_PARTY CANDIDATE_OFFICE CANDIDATE_DISTRICT CANDIDATE_STATE EXPEND_AMT EXPENDITURE_STATE EXPEND_DATE ELE))
 ("spl" (SuperPacName CommitteeID Treasurer SuperPacAddr1 SuperPacAddr2 SuperPacCity SuperPacZip SuperPacState))
 )) ;could get headers right from csv file
(defvar *c2i* '( ;what to mark as an ins ;1st one could be c2ic ;can do later
 ("aic" (CONTRIBKEY commID CONTRIBID)) ;@some point other things could be ins
 ("can" (candidateID))
 ("com" (commID))
 ("spd" (SUPER_PAC_ID TRANS_ID)) ;lines w/^M
 ("spe" (SPENDING_COMM_ID  CANDIDATE_ID))
 ("spl" (CommitteeID))
 )) ;could get headers right from csv file
(defvar *c2ic* '( ("aic" commID) ("can" candidateID) ("com" commID) ("spd" SUPER_PAC_ID)
 ("spe" SPENDING_COMM_ID) ("spl" CommitteeID))) ;could get headers right from csv file
(defvar *c2icn* (mapcar #'cons
                        (mapcar #'first *c2h*)
                        (mapcar #'position (mapcar #'second *c2ic*) (mapcar #'second *c2h*))
                        ))
;- shows which position is to be used for the ins name
;load&dump w/cl-neo4j &sv-al 2km &cmp ;mb
;(load "c2h.cl") ;has csv header info, incl above now
(load-kb "c1.km") ;/FEC_GRAPH/DATA> wc c1.km 7      28     226 c1.km
;map&convert just n lines
(defun i-lt-n-p (i n)
  (if (numberp n) (< i n)
    t)) 
(defun apply-lines-n (filename linefnc &optional (n nil))
 (let ((tot 0))
  (with-open-file (stream filename :direction :input)
    (loop for line = (read-line stream nil)
        while (and line (i-lt-n-p tot n))
        do 
        (incf tot)
        (funcall linefnc line)))))
;want to either collect csv lines, or mk km ins w/o collecting, which is preferable for large n
(defun csv-bar (l) (csv_parse-str l :separator #\|))

 
;-redone, to give class.txt mkclskm
;(defun 2l2alst (l1 l2) (mapcar #'cons l1 l2)) ;(defun mkhl (h l) (2l2alst h l))
(defun mkhl (h l) 
  "alst of:csv header&list of values for a line"
  (rm-nil (mapcar #'(lambda (a b) (when b (cons a b))) h l)))

(defun mkalst-n (a b n) 
  "mk alst except for nth vals"
  (loop for ia in a 
        for ib in b 
        for count = 0 then (+ count 1)
        unless (= count n) collect (cons ia ib)))


(defun first-nonnil (l) (first (rm-nil l)))
               ;(i (or (first l) (second l)))
(defun assoc2 (a b) 
  "val/2nd of assoc"
  (let ((as (assoc a b :test #'equal)))
    (when as (cdr as)))) ;was second

(defun assoc2nd (a b) 
  "val/2nd of assoc"
  (let ((as (assoc a b :test #'equal)))
    (when as (second as)))) ;was second

(defun mkclskm (cls &optional (n 19555)) ;w/clean cls.txt get all ins from most files now
  "make-class2km:  was prs-barfile cls.txt, &optional n, &map flet/lambda over it"
  (let* ((f (str-cat cls ".txt"))
         (h (assoc2nd cls *c2h*))
         (ial (assoc2nd cls *c2i*)) ;ins attr list ;mark each w/*  ;finish
         (ina (first ial)) ;ins name attr, use to name it ;used to assume 1st attrib
         (in (assoc2 cls *c2icn*)) ;num of ina more useful
        )
    (format t "~%f=~a h=~a ~%ial=~a ina=~a in=~a" f h ial ina in)
    (apply-lines-n f
      #'(lambda (s)
         (let* ((l (csv-bar s)) ;the values for that line
               ;;(i (first-nonnil l)) ;might pass in attr for ID
               ;(in (assoc2 cls *c2icn*))
                (i (nth in l)) ;ins-named w/attrib of (usually 1st id-attrib)
                ) ;rm in-th from alst 2 assert, as redundant
            (sv-cls i cls)
           ;(sv-al i (mkhl h l))
            (sv-al i (mkalst-n h l in))
            ))
      n)))
;
;(trace sv-al)
;(trace csv-bar sv-al)
;(trace mkhl sv-al assoc2)
;
(defun init-fec ()
  (mapcar #'mkclskm (mapcar #'first *c2h*))
 ;(mkclskm "aic") (mkclskm "can") (mkclskm "com")
 ;(mkclskm "spd") (mkclskm "spe") (mkclskm "spl")
  )
(defun tst ()
  "try it"
  (init-fec)
  ;(taxonomy)
  (save-kb "19555.km")
  )
;taxonomy to look at it, when limin n=5
;Thing
;   fec
;      aic
;I        *C00000885
;I        *C00000901
;I        *C00000935
;      can
;I        *H0AK00089
;I        *H0AK00097
;I        *H0AL00016
;I        *H0AL01030
;I        *H0AL02087
;      com
;I        *C00000042
;I        *C00000059
;I        *C00000422
;I        *C00000489
;I        *C00000547
;      spd
;I        *SA11AI_Individual/Corporation
;      spe
;I        *PROSPERITY_FIRST_INC
;I        *Planned_Parenthood_Action_Fund_Inc.
;I        *RESTORE_AMERICA_S_VOICE_PAC 
;      spl
;I        *AMERICAN_CROSSROADS
;I        *CLUB_FOR_GROWTH_ACTION
;I        *PRIORITIES_USA_ACTION
;I        *RESTORE_OUR_FUTURE_INC
;I        *WINNING_OUR_FUTURE
;USER(2): (show "C00000885")
;(*C00000885 has 
;  (instance-of (aic))
;  (COMMID (C00000885)) ;will make more ins refs
;  (CONTRIBDATE (((4062012) && (5132011))))
;  (CONTRIBSEARCHDATE (((20120406) && (20110513))))
;  (CONTRIBAMT (250.0))
;  (CONTRIBTYPE (15))
;  (CONTRIBID (((34616053) && (33352920))))) 
;;Right now loading top of processed version of: 
;s24daedalus: /FEC_GRAPH/DATA> wc *.dta
;  419654 1283464 37892260 allIndivContrib1.dta
;  408164 1232079 37047002 allIndivContrib2.dta
;  415655 1266317 37512091 allIndivContrib3.dta
;  414320 1260903 37477088 allIndivContrib4.dta
;  330351 1005863 29879819 allIndivContrib5.dta
;    5400   46541  663755 candidate.dta
;   13141  234574 2229492 committee.dta
;  629736 4338122 66713912 indivContrib1.dta
;  811165 5732726 85724442 indivContrib2.dta
;       0   96926 1960938 superPacDonors.dta
;       0  155134 2943020 superPacExpend.dta
;       0    7336   63880 superPacList.dta
; 3447586 16659985 340107699 total
;defualts: u2 imports vals as strings, ans u2km as eval values; so some sed for this;could automate
; incl attribID ins vals having *ins so will connect to ins; can save-kb&quickly edit for 1st shot
;Wanted to try the hack-night's queries, but they still haven't posted them,&I'm tired of waiting.
;Note, I'm using ~100lines vs. the 2087    5727   76859 total for the java loader that didn't compile 
