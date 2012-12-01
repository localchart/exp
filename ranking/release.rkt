#lang racket/base
(require racket/list
         racket/match
         racket/format
         racket/file
         racket/port
         racket/runtime-path
         net/url
         json
         file/sha1
         file/dbm
         file/org-mode)

(define current-api-key (make-parameter ""))

(define (make-api-url path more)
  (url "http"
       #f
       "api.giantbomb.com"
       #f
       #t
       (map (λ (p) (path/param p empty))
            path)
       (list* (cons 'api_key (current-api-key))
              (cons 'format "json")
              more)
       #f))

(define current-call/input-url (make-parameter call/input-url))

(define (api-url->json the-url)
  ((current-call/input-url)
   the-url
   get-pure-port
   read-json))

(define (game-info-release ht)  
  (define ord 
    (or (hash-ref ht 'release_date #f)
        (hash-ref ht 'original_release_date #f)
        'null))
  (define erm (hash-ref ht 'expected_release_month))
  (define ery (hash-ref ht 'expected_release_year))
  (if (eq? 'null ord)
    (match erm
      ['null
       (~a ery)]
      [_
       (~a ery "/" (~a #:min-width 2
                       #:align 'right
                       #:left-pad-string "0"
                       erm))])
    (regexp-replace #rx"^(....)-(..)-(..) .+$"
                    ord
                    "\\1/\\2/\\3")))

(define (game-search game-name)
  (hash-ref
   (api-url->json
    (make-api-url (list "search" "")
                  (list (cons 'resources "game")
                        (cons 'query game-name))))
   'results))

(define (make-cached-call/input-url cache)
  (define (the-call/input-url url port-kind port-f)
    (define db (dbm-open cache))
    (define s (url->string url))
    (define h (sha1 (open-input-string s)))
    (define c
      (dbm-ref db h
               (λ ()
                 (define c
                   (call/input-url url port-kind
                                   port->string))
                 (dbm-set! db h c)
                 c)))
    (dbm-close! db)

    (with-input-from-string c port-f))
  the-call/input-url)

(module+ main
  (define-runtime-path db-pth "url.cache.db")
  
  (current-api-key
   "60fcf6401d6ad9c37f8daf603352fdedf36c6514")
  (current-call/input-url
   (make-cached-call/input-url db-pth))

  (define path "/home/jay/Dev/scm/github.jeapostrophe/home/etc/games.org")
  (match-define (list games meta) (with-input-from-file path read-org))

  (define stop? #f)
  (define new-games-children
    (for/list ([g (in-list (node-children games))])
      (let/ec return
        (when stop?
          (return g))
        (define ns (node-props g))
        (when (hash-has-key? ns "Release")
          (return g))

        (define n (node-label g))
        (printf "~v (~a ~a)\n"
                n
                (hash-ref ns "Year")
                (hash-ref ns "System"))

        (define gbs (game-search n))
        (define gb-releases
          (sort
           (remove-duplicates
            (append-map
             (λ (gb)
               (define gb-deets
                 (hash-ref
                  (api-url->json
                   (make-api-url
                    (list "game"
                          (number->string (hash-ref gb 'id))
                          "")
                    empty))
                  'results))

               (map (λ (ht)
                      (define release
                        (hash-ref
                         (api-url->json
                          (make-api-url
                           (list "release"
                                 (number->string (hash-ref ht 'id))
                                 "")
                           empty))
                         'results))
                      (vector (game-info-release release)
                              (hash-ref gb 'name)
                              (hash-ref (hash-ref release 'platform)
                                        'name)))
                    (hash-ref
                     gb-deets
                     'releases)))
             gbs))
           string<=?
           #:key (λ (v) (vector-ref v 0))))

        (define gb-dates
          (for/list ([gb (in-list gb-releases)]
                     [i (in-naturals)])
            (match-define (vector gb-date gb-n gb-platform) gb)
            (printf "\t~a. ~a ~a: ~v\n"
                    i (~a #:min-width 10 gb-date) gb-n gb-platform)
            gb-date))
        (printf "\ts. skip\n")
        (printf "\tq. quit\n")

        (match (read)
          [(? number? n)
           (when (<= (length gb-dates) n)
             (return g))
           (define gb-date (list-ref gb-dates n))
           (struct-copy node g
                        [props (hash-set ns "Release" gb-date)])]
          ['s
           (return g)]
          [_
           (set! stop? #t)
           (return g)]))))

  (define new-games
    (struct-copy
     node games
     [children new-games-children]))

  (with-output-to-file path
    #:exists 'replace
    (λ () (write-org (list new-games meta)))))