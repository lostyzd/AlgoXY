;; Alphabetic Trie

(load "trieutil.scm")

;; Definition

(define (make-trie v lop) ;; v: value, lop: children, list of char-trie pairs
  (cons v lop))

(define (value t)
  (if (null? t) '() (car t)))

(define (children t)
  (if (null? t) '() (cdr t)))

(define (make-child k t)
  (cons k t))

(define (key child)
  (if (null? child) '() (car child)))

(define (tree child)
  (if (null? child) '() (cdr child)))

(define (string-car s)
  (string-head s 1))

(define (string-cdr s)
  (string-tail s 1))

;; Insertion
(define (insert t k x)
  (define (ins lst k ks x) ;; return list of child
    (if (null? lst)
	(list (make-child k (insert '() ks x)))
	(if (string=? (key (car lst)) k)
	    (cons (make-child k (insert (tree (car lst)) ks x)) (cdr lst))
	    (cons (car lst) (ins (cdr lst) k ks x)))))
  (if (string-null? k) 
      (make-trie x (children t))
      (make-trie (value t) 
		 (ins (children t) (string-car k) (string-cdr k) x))))

;; Lookup
(define (lookup t k)
  (define (find k lst)
    (if (null? lst) '()
	(if (string=? k (key (car lst)))
	    (tree (car lst))
	    (find k (cdr lst)))))
  (if (string-null? k) (value t)
      (let ((child (find (string-car k) (children t))))
	(if (null? child) '()
	    (lookup child (string-cdr k))))))

;; Test helpers

;; sort children base on keys
(define (sort-children lst)
  (if (null? lst) '()
      (let ((xs (filter (lambda (c) (string<=? (key c) (key (car lst)))) 
			(cdr lst)))
	    (ys (filter (lambda (c) (string>?  (key c) (key (car lst)))) 
			(cdr lst))))
	(append (sort-children xs) 
		(list (car lst))
		(sort-children ys)))))

(define (trie->string t)
  (define (value->string x)
    (cond ((null? x) ".")
	  ((number? x) (number->string x))
	  ((string? x) x)
	  (else "unknon value")))
  (define (trie->str t prefix)
    (define (child->str c)
      (string-append ", " (trie->str (tree c) (string-append prefix (key c)))))
    (let ((lst (map child->str (sort-children (children t)))))
      (string-append "(" prefix (value->string (value t))
		     (fold-left string-append "" lst) ")")))
  (trie->str t ""))

(define (test-trie)
  (define t (list->trie (list '("a" 1) '("an" 2) '("another" 7) '("boy" 3) '("bool" 4) '("zoo" 3))))
  (define t2 (list->trie (list '("zoo" 3) '("bool" 4) '("boy" 3) '("another" 7) '("an" 2) '("a" 1))))
  (display (trie->string t)) (newline)
  (display (trie->string t2)) (newline)
  (display "lookup an: ") (display (lookup t "an")) (newline)
  (display "lookup boy: ") (display (lookup t "boy")) (newline)
  (display "lookup the: ") (display (lookup t "the")) (newline))

;; Find all candidates
(define (find t k)
  (define (find-child lst k)
    (tree (find-matching-item lst (lambda (c) (string=? (key c) k)))))
  (if (string-null? k) 
      (enumerate t) 
      (let ((t-new (find-child (children t) (string-car k))))
	(if (null? t-new) '()
	  (map-string-append (string-car k) (find t-new (string-cdr k)))))))

(define (enumerate t) ;; enumerate all sub trees
  (if (null? t) '()
      (let ((res (append-map 
		  (lambda (p)(map-string-append (key p)(enumerate (tree p))))
		  (children t))))
	(if (null? (value t)) res
	    (cons (cons "" (value t)) res)))))

(define dict 
  (list '("a" "the first letter of English")
	'("an" "used instead of 'a' when the following word begins with a vowel sound")
	'("another" "one more person or thing or an extra amount")
	'("abandon" "to leave a place, thing or person forever")
	'("about" "on the subject of; connected with")
	'("adam" "a character in the Bible who was the first man made by God")
	'("boy" "a male child or, more generally, a male of any age")
	'("bodyl" "the whole physical structure that forms a person or animal")
	'("zoo" "an area in which animals, especially wild animals, are kept so that people can go and look at them, or study them")))

(define (test-trie-find-all)
  (define t (list->trie dict))
  (display "find a*: ") (display (find t "a")) (newline)
  (display "find ab*: ") (display (find t "ab")) (newline))
