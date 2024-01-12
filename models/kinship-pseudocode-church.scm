;; -- Intimacy Kinship in Church --
;; Author: Herrissa Lamothe (hlamothe@mit.edu)
;; With help from Lio Wong. 
;; Code adapted from Gabe Grand's "Kinship in Church" original code.

;; -- GENERAL UTILITIES --
;; Membership test that returns true instead of literal list
(define (member? a b)
  (if (member a b) true false))


;; Shuffle a list. Relies on items in the list being unique.
(define (shuffle-unique lst)
  (if (null? lst)
      ()
      (let* ((n (random-integer (length lst)))
             (x (list-ref lst n)))
      (cons x (shuffle-unique (difference lst (list x)))))))

;; Convenience method for accessing properties in association lists
(define (lookup obj key)
  (if (assoc key obj) (rest (assoc key obj)) ()))

;; Shallow flatten
(define (shallow-flatten x)
  (cond ((null? x) '())
        ((pair? x) (append (car x) (shallow-flatten (cdr x))))
        (else (list x))))

;; -- WORLD INITIALIZATION --
;; Select size of world (hard-coded as size 6 for now)
(define WORLD-SIZE 6)

;; All the names that can be used in the conversational context.
(define ALL-NAMES '(avery blake charlie dana aubrey campbell))

;; Replace unknown names with "other" (for histograms)
(define (mask-other names)
  (map (lambda (name)
         (cond
           ((null? name) name)
           ((member? name ALL-NAMES) name)
           (else "other")))
        names))

;; -- WORLD MODEL --
(define (run-world-model)
  (rejection-query
   
   ;; Generates unique person ids of the format (person-0, person-1, ...)
    (define PERSON-PREFIX "person-")
    (define new-person-id (make-gensym PERSON-PREFIX))
    (define (id->idx person-id)
      (string->number (string-slice (stringify person-id) (string-length PERSON-PREFIX))))
   
    ;; Randomly assign a gender
    (define person->gender (mem (lambda (person-id)
      (uniform-draw '(male female)))))
   
    ;; Randomly assign an age in (1 100)
    ;; HL COMMENT: the granularity (binning) with which age is assigned needs to be set for different observer's world models
    (define person->age (mem (lambda (person-id)
      (gaussian 1 100))))
   
    ;; Randomly-ordered list of person names
    (define NAMES (shuffle-unique ALL-NAMES))
    (define person->name (mem (lambda (person-id) ; HL Question: why is this not used below to assign a name?
      (list-ref NAMES (id->idx person-id)))))
   
    ;; Randomly assign a set of intimate-ids
    ;; HL COMMENT: use a formal graph based approach for world generation next time? See White (1963)
    (define person->ties (mem (lambda (person-id)
      (define FILTERED-NAMES 
        (filter (lambda (name) (not (equal? name (person->name person-id)))) NAMES))
      (define maxIndex
        (- (length FILTERED-NAMES) 1))
      (define (random-sample-ties FILTERED-NAMES maxIndex)
        (let ((index (random maxIndex)))
          (list-ref FILTERED-NAMES index))))))
   
    ;; Person node in graph
    (define (person person-id . intimate-ids) (list
      (pair 'person-id person-id)
      (pair 'name (person->name person-id)) ; HL COMMENT: I assigned the name here using "person->name person-id" instead of original: 'name person-id'
      (pair 'gender (person->gender person-id))
      (pair 'age (person->age person-id))                                       
      (pair 'intimate-ids intimate-ids))) ; PENDING
   
   ;; Generate full graph
   (define (generate-graph ego-primary-id ego-secondary-id WORLD-SIZE)
      (let* (
            ;; Create the primary ego))
            (ego-1-id (new-person-id))
            (ego-1 (person ego-1-id ego-primary-id () ))
        
            (ego-2-id (new-person-id))
            (ego-2 (person ego-2-id () ego-secondary-id))))
        
            ;; Generate intimacy relations for ego 1 and 2
       (let* (
            (ego-1-intimate-ties (person->ties ego-1-id))
            (n-intimate-ties-ego-1 (length((ego-1-intimate-ties))))
            (ego-1-intimate-graph (repeat n-intimate-ties-ego-1 (lambda () generate-graph ego-1-id ego-2-id WORLD-SIZE)))
            
            (ego-2-intimate-ties (person->ties ego-2-id))
            (n-intimate-ties-ego-2 (length((ego-2-intimate-ties))))
            (ego-2-intimate-graph (repeat n-intimate-ties-ego-2 (lambda () generate-graph ego-1-id ego-2-id WORLD-SIZE)))

            ;; Update egos to point to their intimate relationships
            (ego-1-intimate-ids (map (lambda (t) lookup (first t) 'person-id)) ego-1-intimate-graph) ; HL COMMENT: How is there already an ID associated with the ties?
            (ego-1 (append ego-1 (list (pair 'intimate-ids ego-1-intimate-ids))))
         
            (ego-2-intimate-ids (map (lambda (t) lookup (first t) 'person-id)) ego-2-intimate-graph) ; HL COMMENT: Should already have their names?
            (ego-2 (append ego-2 (list (pair 'intimate-ids ego-2-intimate-ids))))
              

        (append (list ego-1) (list parent-2) (shallow-flatten child-trees))))) ; HL COMMENT: is shallow-flatten the right way to deal w/ two ego lists?
   
     ;; Generate the global graph   
     (define T (generate-tree () () 0))
   
     ;; -- CORE TREE UTILITIES --

         
   ;; Print intimacy graph generated?
