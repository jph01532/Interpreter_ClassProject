#lang eopl

;John Halloran and Jakob Horner

(define-datatype lc-exp lc-exp?
  (var-exp
   (var symbol?))
  (lambda-exp
   (bound-var (list-of symbol?))
   (body lc-exp?))
  (app-exp
   (rator lc-exp?)
   (rand (list-of lc-exp?))))

(define parse-expression
    (lambda (datum)
	(cond
          ((symbol? datum) (var-exp datum))
          ((pair? datum)
           (if (eqv? (car datum) 'lambda)
               (lambda-exp
                (cadr datum)
                (parse-expression (caddr datum)))
               (app-exp
                (parse-expression (car datum))
                (map parse-expression (cdr datum))))) 
          (else (report-invalid-concrete-syntax datum)))
    )
)

(define report-invalid-concrete-syntax
  (lambda (datum)
    (eopl:error 'datum "Invalid Syntax for datum")))

(define unparse-lc-exp
    (lambda (exp)
	(cases lc-exp exp
          (var-exp (var) var)
          (lambda-exp (bound-var body)
             (list 'lambda bound-var
               (unparse-lc-exp body)))
          (app-exp (rator rand)
             (cons
              (unparse-lc-exp rator) (map unparse-lc-exp rand)))
)))

(define occurs-free? 
    (lambda (lst)
      (cons 'a ('b))
      ))

(define occurs-bound?
  (lambda (lst)
    (cons 'a ('b))
    ))




(provide lc-exp parse-expression unparse-lc-exp occurs-free? occurs-bound?)