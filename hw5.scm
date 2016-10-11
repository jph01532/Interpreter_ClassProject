#lang eopl


(require "hw2m.scm")

;John Halloran and Jakob Horner 

;This is where we will put the scanner stuff from the example in class
(define scanner-spec-lc
'((white-sp (whitespace)  skip)
  (comment  ("%" (arbno (not #\newline)))  skip)
  (identifier (letter (arbno (or letter digit "?"))) symbol)
  (number   (digit (arbno digit))  number)))

;This is the grammar specified in homework specs
(define expression-grammar
  '((a-program (exp) prog-exp)
    
    (exp (number) const-exp)
    (exp (identifier) var-exp)
    (exp ("(" sub-exp ")") shell-exp)

    (sub-exp ("cond" "(" (arbno exp exp  ")""(") "else" exp ")") cond-exp)
    (sub-exp  ("lambda" "(" (arbno identifier) ")" exp) proc-exp) 
    (sub-exp (exp (arbno exp)) cal-exp)
               
    (sub-exp ("if" boolexp exp exp) if-exp)
    (sub-exp ("let" "(" (arbno sublet-exp) ")" exp) let-exp)
    (sublet-exp ("(" identifier exp ")") slet-exp)
    
    (boolexp ("#" sub-boolval)  pound-exp)
    (sub-boolval ("t") true-exp)
    (sub-boolval ("f") false-exp)
    ))

(define scan&parse (sllgen:make-string-parser scanner-spec-lc expression-grammar))
(sllgen:make-define-datatypes scanner-spec-lc expression-grammar)

(define run
  (lambda (string)
    (value-of-program (scan&parse string))
   ))

(define value-of-program
  (lambda (pgm)
    (cases a-program pgm
      (prog-exp (exp)
         (value-of exp (extend-env "add"  (empty-env))))
      (else
       (eopl:error 'pgm "Improper program ~s" pgm))
      )))

(define value-of
 (lambda (ex env)
  (cases exp ex
    ;case for constant expressions
    (const-exp (num) num)
    ;case for variable expressions
    (var-exp (var) (apply-env env var))
    ;case for general expressions
    (shell-exp (body) (value-of-body body env))
    (else
       (eopl:error 'ex "Improper expression ~s" ex))
   )))

;value of a general expression
(define value-of-body
  (lambda (exp env)
    (cases sub-exp exp
      ;case for if expressions
      (if-exp (bool exp1 exp2)
        (cond
          ((value-of-bool bool env) (value-of exp1 env))
        (else (value-of exp2 env))))
      ;case for let expressions  
      (let-exp (lstexp exp1)
        (value-of exp1 (sublet-iterator lstexp env)) 
      )
      (else
       (eopl:error 'exp "Improper subexpression ~s" exp))
      )))

;helper function to go through the list of sublet expressions
(define sublet-iterator
  (lambda (exp env);exp is a list and env is the environment 
    (cond
      ((null? exp) env)
      (else(sublet-iterator (cdr exp) (value-of-subletexp (car exp) env)))
  )))

;helper function for let expression
(define value-of-subletexp
  (lambda (exp env)
    (cases sublet-exp exp
      (slet-exp (id exp1)
        (extend-env id (value-of exp1 env) env);returns environment
        )
      (else
       (eopl:error 'exp "Improper sublet expression ~s" exp))
      )))
      
(define value-of-bool
  (lambda (bool env)
    (cases boolexp bool
      (pound-exp (subbool)
         (evaluate-pound subbool))
      (else
       (eopl:error 'bool "Improper boolean ~s" bool))
      )))

(define evaluate-pound
  (lambda (subbool)
    (cases sub-boolval subbool
      (true-exp ()
         #t)
      (false-exp ()
         #f)
      (else
       (eopl:error 'subbool "Improper boolean ~s" subbool))
      )))

(provide scan&parse run)


;TA-BOT:MAILTO john.p.halloran@marquette.edu jakob.horner@marquette.edu