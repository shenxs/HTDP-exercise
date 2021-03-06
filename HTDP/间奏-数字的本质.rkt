#lang racket
;; 在计算机硬件中,用固定大小的容器来存放数字。
;; 但是，人们在用纸笔进行计算时，并不关心一个数字到底有多少位数，因为理论上我们可以处理任意长度的数字
;; 编程语言在实现数字计算时，如果从硬件角度考虑（因为容器的大小限制了一个数字的大小），那么计算机计算起来速度非常快
;; 如果我们希望长度可以不受限制，就需要把数字合理的放到这些容器里面，读取时在把他们正确的拿出来，这之间就需要耗费时间
;; 因此大多数的语言实现都会采用前者

;; 第四章的间奏曲包括以下几个部分
;; -怎样把数字用固定大小的数据表示，以及如何在此基础上进行计算
;; -第二和第三部分强调了这么做的最基本的两个问题算数上溢（数据太大放不下）和算数下溢（数据精度太大无法表示）
;; -最后似乎时介绍了racket教学语言的数字系统如何工作，以及计算数字时事情会变得多遭

;;------固定大小的数字-------
;使用科学计数法表示
;由两部分组成系数和指数,默认的底数是10
; N Number N -> Inex
; make an instance of Inex after checking the arguments

;系数 指数 以及指数的正负
(define-struct inex [mantissa sign exponent])
(define (create-inex m s e)
  (cond
    [(and (<= 0 m 99) (<= 0 e 99) (or (= s 1) (= s -1)))
     (make-inex m s e)]
    [else
     (error 'inex "(<= 0 m 99), s in {+1,-1}, (<= 0 e 99) expected")]))

; Inex -> Number
; convert an inex into its numeric equivalent
(define (inex->number an-inex)
  (* (inex-mantissa an-inex)
     (expt 10 (* (inex-sign an-inex) (inex-exponent an-inex)))))

;Exercise 387
;将两个inex相加,两个数字拥有相同的指数可以自动调整系数,并且不依赖creat-inex来报错
;系数可以相差1,指数相同见git历史版本
;inex inex ==> inex
(define (inex+ i1 i2)
  (local (
          (define e1 (* (inex-sign  i1) (inex-exponent i1)))
          (define e2 (* (inex-sign  i2) (inex-exponent i2)))
          (define e (max e1 e2))
          (define m (cond
                      [(= e1 e2) (+ (inex-mantissa i1) (inex-mantissa i2))]
                      [(> e1 e2) (+ (inex-mantissa i1) (floor (/ (inex-mantissa i2) 10)))]
                      [(< e1 e2) (+ (floor (/ (inex-mantissa i1) 10)) (inex-mantissa i2))]))
          (define real_m (if (> m 99)
                           (floor (/ m 10))
                           m))
          (define real_e (if (> m 99)
                           (+ e 1)
                           e))
          (define sign (if (< real_e 0) -1 1)))
    ;;-----IN------
    (cond
      [(and (<= 0 real_m 99) (<= 0 real_e 99) (or (= sign 1) (= sign -1)))
       (make-inex real_m sign real_e)]
      [else (error 'inex "m∈ [0,99] ,s∈ {-1,1} ,e∈ [0,99]")])))

;; (inex->number (inex+ (create-inex 56 1 1) (create-inex 56 1 0)) )

;Exercise 388
;将两个数相乘

(define (inex* i1 i2)
  (local (
          (define m (* (inex-mantissa i1) (inex-mantissa i2)))
          (define e1 (* (inex-sign i1) (inex-exponent i1)))
          (define e2 (* (inex-sign i2) (inex-exponent i2)))
          (define e (+ e1 e2))
          (define (tiao m e)
            (cond
              [(> m 99) (tiao (floor (/ m 10)) (+ 1 e) )]
              [(not (<= -99 e 99)) (error "指数错误")]
              [else (if (< e 0)
                      (create-inex m -1 (* -1 e))
                      (create-inex m 1 e))]))
          )
    ;----IN----
    (tiao m e)))

;; (inex->number (inex* (create-inex 5 1 90) (create-inex 4 1 1)) )


(define (add n)
  (cond
    [(= n 1) #i1/185]
    [else (+ #i1/185 (add (sub1 n)))]))
;;#i/185与1/185不相等所以
;; (add 185)

(define (sub n)
  (local ((define (count n i)
            (cond
              [(< (- n 0) 0.0001) i]
              [else (count (- n 1/185) (+ 1 i))])))
    (count n 0)))
;; (sub 1.0)
;判断条件不可以用(= n 0) 因为永远不会相等


;;;-----溢出------

(define (big-n n)
  (local ((define (calcu n)
            (expt #i10.0 n)))
    (cond
      [(equal? +inf.0 (calcu n)) n]
      [else (big-n (+ 1 n))])))

;; (big-n 0)


;;;-----下溢----
(define (small-n n)
  (local ((define (calcu n)
            (expt #i10.0 n)))
    (cond
      [(equal? #i0.0 (calcu n)) n]
      [else (small-n (- n 1))])))

(small-n 0)


;;;;SL-Number-------
(expt 1.001 1e-12)

;Exercise 393
(define (my-expt n p)
  (cond
    [(= 0 p) 1 ]
    [else (* n (my-expt n (sub1 p)))]))
(define INEX (+ 1 #i1e-12))
(define EXAC (+ 1 1e-12))

(my-expt INEX 30)

(my-expt EXAC 30)

