(put 'begin 'scheme-indent-function 0)
(put 'begin-for-syntax 'scheme-indent-function 0)
(put 'case 'scheme-indent-function 1)
(put 'cond 'scheme-indent-function 0)
(put 'delay 'scheme-indent-function 0)
(put 'do 'scheme-indent-function 2)
(put 'lambda 'scheme-indent-function 1)
(put 'λ 'scheme-indent-function 1)
(put 'lambda: 'scheme-indent-function 1)
(put 'case-lambda 'scheme-indent-function 0)
(put 'lambda/kw 'scheme-indent-function 1)
(put 'define/kw 'scheme-indent-function 'defun)
(put 'let 'scheme-indent-function 'scheme-let-indent)
(put 'let* 'scheme-indent-function 1)
(put 'letrec 'scheme-indent-function 1)
(put 'let-values 'scheme-indent-function 1)
(put 'let*-values 'scheme-indent-function 1)
(put 'fluid-let 'scheme-indent-function 1)
(put 'let/cc 'scheme-indent-function 1)
(put 'let/ec 'scheme-indent-function 1)
(put 'let-id-macro 'scheme-indent-function 2)
(put 'let-macro 'scheme-indent-function 2)
(put 'letmacro 'scheme-indent-function 1)
(put 'letsubst 'scheme-indent-function 1)
(put 'sequence 'scheme-indent-function 0) ; SICP, not r4rs
(put 'letsyntax 'scheme-indent-function 1)
(put 'let-syntax 'scheme-indent-function 1)
(put 'letrec-syntax 'scheme-indent-function 1)
(put 'syntax-rules 'scheme-indent-function 1)
(put 'syntax-id-rules 'scheme-indent-function 1)

(put 'call-with-input-file 'scheme-indent-function 1)
(put 'call-with-input-file* 'scheme-indent-function 1)
(put 'with-input-from-file 'scheme-indent-function 1)
(put 'with-input-from-port 'scheme-indent-function 1)
(put 'call-with-output-file 'scheme-indent-function 1)
(put 'call-with-output-file* 'scheme-indent-function 1)
(put 'with-output-to-file 'scheme-indent-function 'defun)
(put 'with-output-to-port 'scheme-indent-function 1)
(put 'with-slots 'scheme-indent-function 2)
(put 'with-accessors 'scheme-indent-function 2)
(put 'call-with-values 'scheme-indent-function 2)
(put 'dynamic-wind 'scheme-indent-function 0)

(put 'if 'scheme-indent-function 1)
(put 'method 'scheme-indent-function 1)
(put 'beforemethod 'scheme-indent-function 1)
(put 'aftermethod 'scheme-indent-function 1)
(put 'aroundmethod 'scheme-indent-function 1)
(put 'when 'scheme-indent-function 1)
(put 'unless 'scheme-indent-function 1)
(put 'thunk 'scheme-indent-function 0)
(put 'while 'scheme-indent-function 1)
(put 'until 'scheme-indent-function 1)
(put 'parameterize 'scheme-indent-function 1)
(put 'parameterize* 'scheme-indent-function 1)
(put 'syntax-parameterize 'scheme-indent-function 1)
(put 'with-handlers 'scheme-indent-function 1)
(put 'with-handlers* 'scheme-indent-function 1)
(put 'begin0 'scheme-indent-function 0)
(put 'with-output-to-string 'scheme-indent-function 0)
(put 'ignore-errors 'scheme-indent-function 0)
(put 'no-errors 'scheme-indent-function 0)
(put 'matcher 'scheme-indent-function 1)
(put 'match 'scheme-indent-function 1)
(put 'regexp-case 'scheme-indent-function 1)
(put 'dotimes 'scheme-indent-function 1)
(put 'dolist 'scheme-indent-function 1)

(put 'with-syntax 'scheme-indent-function 1)
(put 'syntax-case 'scheme-indent-function 2)
(put 'syntax-case* 'scheme-indent-function 3)
(put 'module 'scheme-indent-function 2)

(put 'syntax 'scheme-indent-function 0)
(put 'quasisyntax 'scheme-indent-function 0)
(put 'syntax/loc 'scheme-indent-function 1)
(put 'quasisyntax/loc 'scheme-indent-function 1)

(put 'cases 'scheme-indent-function 1)

(put 'for 'scheme-indent-function 1)
(put 'for* 'scheme-indent-function 1)
(put 'for/list 'scheme-indent-function 1)
(put 'for*/list 'scheme-indent-function 1)
(put 'for/fold 'scheme-indent-function 2)
(put 'for*/fold 'scheme-indent-function 2)
(put 'for/and 'scheme-indent-function 1)
(put 'for*/and 'scheme-indent-function 1)
(put 'for/or 'scheme-indent-function 1)
(put 'for*/or 'scheme-indent-function 1)

(put 'nest 'scheme-indent-function 1)
