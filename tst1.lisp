;First pass using my utils, later in Ruby  ;M Bobak
;Users like the chemical inventory system you built for them, but sometimes they unexpectedly run out of a chemical and have to wait for resupply. After discussing this with them, you realize that many uses recur at defined intervals, and this can help you forecast when the chemical will run out.
;
;Scheduled use
;A scheduled use has an amount, a periodicity, a start date and an optional end date
;A scheduled use's periodicity can be daily or weekly (on a particular day of the week)
;Given a current amount and a set of scheduled uses, predict when the chemical will run out
;If the last use brings the amount to zero, then return the date of the last use
;If any use makes the amount negative, return the date of the latest use that did not incur a negative balance
;=Start w/test data in code, then read-csv or other (as soon as I find out ways it is listed)
;can have resupply times that differ, but assume order as much as same time&they all come in a stnd time

;in KM, put in utils in case km not loaded
;defun split-at1 (string substring &key from-end)
;defun string-to-number (string &key (fail-mode 'fail))
 
;lhstat
;defun linear-regression (points)
;;; sequence of points (each a list of two numbers, e.g. '((1.0 0.1) (2.0 0.2)))

;;; Start w/1product and one timeline since the last restock, @each use have a time-till-out estimate
;;; factor in restock time, and w/other products might bundle but if from diff vendors can ingnore

;instance will have lastRestockTime(as start), that stockingLevel, & (restock)R-eta which will be put in terms of days out from present time
;sL - burnRate * time = timeOut
(defvar *sL* 800)
(defvar *br* 0.5) ;12units/day  or 4/8hr period  or 0.5 units/hr
(defun curStock-h (h) (- *sL* (* *br* h))) ;or deltH only if sL updated 
;product1 useTimesSinceLastRestock  ;w/very roughly monthly(720hr)or so ave restock times
;-do by hand or generate:
(defun rn (&optional (m 0) (s 4)) (statistics:random-normal :mean m :sd s))
;(loop for h from 2 to 700 by 8 collect (list  (rn h 2)  (rn (curStock-h h) ))) ;to gen cached values below
;(loop for h from 2 to 700 by 8 collect (list  (floor (rn h 2))  (floor (rn (curStock-h h))))) ;to gen cached values below
(defvar *p1-utslr* '( ;could have drop a little faster, but fine for now
 (1 794) (9 799) (18 790) (27 792) (35 783) (41 783) (49 779) (58 770) (64 770)
 (72 768) (79 758) (90 747) (99 746) (105 733) (113 738) (120 737) (128 730)
 (135 728) (142 731) (154 720) (158 721) (168 718) (176 703) (184 702)
 (189 703) (203 702) (213 685) (218 687) (221 683) (234 679) (241 671)
 (249 679) (256 675) (268 665) (276 664) (278 654) (289 657) (297 646)
 (307 650) (312 647) (322 642) (330 638) (339 633) (344 627) (352 627)
 (362 619) (372 612) (382 610) (385 607) (391 606) (397 598) (404 593)
 (416 591) (425 584) (432 586) (444 578) (453 577) (454 571) (463 571)
 (473 556) (484 563) (492 555) (493 549) (505 544) (511 542) (522 538)
 (531 538) (539 534) (546 523) (555 526) (560 520) (571 519) (579 504)
 (582 506) (593 504) (601 500) (611 489) (615 485) (626 486) (633 480)
 (644 483) (650 474) (657 473) (665 455) (674 461) (680 453) (692 455)
 (692 451)) 
)
(defun ff (n) (* 1.0 (floor n)))
;or(loop for h from 2 to 700 by 8 collect (list (ff (rn h 2))  (ff (rn (curStock-h h))))) 
;then (STATISTICS:LINEAR-REGRESSION *P1-UTSLR*) to get zero-crossing, &calc eta
;(defun t1 () (statistics:linear-regression *p1-utslr*))
;(defun t1 () (statistics:lin-regression *p1-utslr*))
(defun t1 () (statistics:x-int *p1-utslr*))

#+ignore ;in statistics pkg right now
(defun x-int (points) ;a version of lin-regression (points)
  (test-variables (points sequence))
  (let  ((xs (map 'list #'first points))
         (ys (map 'list #'second points)))
    (test-variables (xs :numseq) (ys :numseq))
    (let* ((x-bar (mean xs))
           (y-bar (mean ys))
           (n (length points))
           (Lxx (reduce #'+ (mapcar (lambda (xi) (square (- xi x-bar))) xs)))
           (Lyy (reduce #'+ (mapcar (lambda (yi) (square (- yi y-bar))) ys)))
           (Lxy (reduce #'+ (mapcar (lambda (xi yi) (* (- xi x-bar) (- yi y-bar)))
                                    xs ys)))
           (b (/ Lxy Lxx))
           (a (- y-bar (* b x-bar)))
           (reg-ss (* b Lxy))
           (res-ms (/ (- Lyy reg-ss) (- n 2)))
           (r (/ Lxy (sqrt (* Lxx Lyy))))
           (r2 (/ reg-ss Lyy))
           (t-test (/ b (sqrt (/ res-ms Lxx))))
          ;(t-significance (t-significance t-test (- n 2) :tails :both))
           (x-int (- (/ a b)))
           )
      ;format t "~%Intercept = ~f, slope = ~f, r = ~f, R^2 = ~f, p = ~f"
      (format t "~%Intercept = ~f, slope = ~f, r = ~f, R^2 = ~f"
              a b r r2 )
     ;(values a b r r2 )
     x-int)))
;USER(1): (t1)
;Intercept = 798.605, slope = -0.4998287, r = -0.9991366, R^2 = 0.998274
;23247687494/14550199
;USER(2): (* 1.0 *)
;1597.7573
;USER(3): 