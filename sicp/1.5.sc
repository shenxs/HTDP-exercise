;;是按需求值还是正常求值

(define (p) (p))

(define (test x y)
  (if (= x 0) 0 y))

(test 0 (p))

;;如果是正常求值会陷入死循环，如果是按需求值会返回0

;;亲测 ，chez scheme是正常求值，并不是按需求值，或者说惰性求值
;;所以会变成死循环。