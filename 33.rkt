#lang racket
;回溯算法
;smaple problem
;给定一张图,两个节点,给出链接两个点的路径

(define sample-graph
  '((A B E)
    (B E F)
    (C D)
    (D)
    (E C F)
    (F D G)
    (G)))

;Exercise 445
(define (translate-graph g)
  (map (λ (node) (cons (first node) (cons (rest node) '())))
       g))

(define graph (translate-graph sample-graph) )

;; 给定图以及一个节点,给出次节点的相邻的节点

(define (neighbors n g)
  (cond
    [(empty? g) (error "no such node in the graph")]
    [(symbol=? n (first (first g))) (first (rest (first g)))]
    [else (neighbors n (rest g) )]))

;; (neighbors 'F graph)

;; Node Node Graph -> [Maybe Path]
;; finds a path from origination to destination in G
;; if there is no path, the function produces #false

(define (find-path origination destination G)
  (cond
    [(eq? origination destination) (list destination)]
    [else (local ((define next (neighbors origination G))
                  (define candidate (find-path/list next destination G)))
            (cond
              [(boolean? candidate) #false]
              [else (cons origination candidate)]))]))

; [List-of Node] Node Graph -> [Maybe Path]
; finds a path from some node on lo-Os to D
; if there is no path, the function produces #false
(define (find-path/list lo-Os D G)
  (cond
    [(empty? lo-Os) #false]
    [else (local ((define candidate (find-path (first lo-Os) D G)))
            (cond
              [(boolean? candidate) (find-path/list (rest lo-Os) D G)]
              [else candidate]))]))

;; (find-path 'A 'G graph)


;; 起点,终点,图===>#false 或正确的联通路径
;start end graph
(define (find-my-path s e g)
  (cond
    [(eq? s e) (list e)]
    [else (local(
                 (define next (neighbors s g))
                 (define maybe (find-my-path/list next e g)))
            (cond
              [(cons? maybe) (cons s maybe)]
              [else #f]))]))

;[list of nodes] [end node] [graph] ===>#f or [list of nodes]
(define (find-my-path/list lon e g)
  (cond
    [(empty? lon) #f]
    [else (local (
                  (define maybe-list
                    (map (λ (x) (find-my-path x e g)) lon))
                  (define (d? item)
                    (if (cons? item) item #f)))
            (ormap d? maybe-list))]))

(find-my-path 'A 'G graph)

;Exercise 446
;对于给定的图,找到任意两点之间的路径,如果成功返回#true else #false
(define (test-on-all-nodes graph)
  (local(
         ;;[a list of list] ===> [a list of item(the first item of the list in the list )]
         ;'((1212 12 12 1) (12 22) (1) (a s)) ====>'(1212 12 1 a)
         (define (get-every-first graph)
           (cond
             [(empty? graph) '()]
             [else (cons (first (first graph)) (get-every-first (rest graph)))]))
         ;;图中所有的节点
         (define lon (get-every-first graph))
         ;;[a node] [a list of node] [graph] ==>#t or #f
         ;测试item 是否和l中的所有的node都相通
         (define (test-one item l g)
           (cond
             [(empty? l) #t]
             [else (local
                     ((define result (cons? (find-path item (first l) g))))
                     (and result (test-one item (rest l) g)))]))
         ;;[list of node] [graph]===>#t or #f
         (define (test-all l g)
           (cond
             [(empty? l) #t]
             [else
               (and (test-one (first l) (rest l) g)
                    (test-all (rest l) g))]))
         )
    (test-all lon graph)))

;; (test-on-all-nodes graph)

;; 定义一个带有环的图的例子
(define circle-graph
  '((A (B C))
    (B (C))
    (C (A))))
