;; Title: VerdictVault - Community Content Validation Protocol
;; 
;; Summary: A revolutionary blockchain-powered platform that transforms how
;; digital content is discovered, evaluated, and monetized through collective
;; intelligence and transparent community governance.
;;
;; Description: VerdictVault establishes a merit-based ecosystem where content
;; quality is determined by community consensus rather than algorithmic bias.
;; The protocol incentivizes thoughtful curation by rewarding accurate evaluators
;; while creating sustainable revenue streams for content creators. Through
;; transparent on-chain governance, users build reputation capital that directly
;; correlates with their contribution quality, fostering a self-regulating
;; community of digital tastemakers and knowledge validators.

;; CORE PROTOCOL CONFIGURATION

(define-constant PROTOCOL_ADMINISTRATOR tx-sender)

;; ERROR HANDLING DEFINITIONS

(define-constant ERR_UNAUTHORIZED_ACCESS (err u100))
(define-constant ERR_INVALID_SUBMISSION (err u101))
(define-constant ERR_DUPLICATE_ENTRY (err u102))
(define-constant ERR_NONEXISTENT_ITEM (err u103))
(define-constant ERR_INADEQUATE_BALANCE (err u104))
(define-constant ERR_INVALID_TOPIC (err u105))
(define-constant ERR_INVALID_FLAG (err u106))
(define-constant ERR_OVERFLOW (err u107))
(define-constant ERR_INVALID_APPRAISAL (err u108))
(define-constant ERR_INVALID_ITEM_ID (err u109))

;; PROTOCOL PARAMETERS

(define-constant MIN_HYPERLINK_LENGTH u10)
(define-constant MAX_UINT u340282366920938463463374607431768211455)

;; GLOBAL STATE VARIABLES

(define-data-var submission-charge uint u10)
(define-data-var aggregate-submissions uint u0)
(define-data-var content-topics 
  (list 10 (string-ascii 20)) 
  (list "Technology" "Science" "Art" "Politics" "Sports")
)

;; DATA STORAGE STRUCTURES

;; Primary content registry with comprehensive metadata
(define-map curated-items 
  { item-identifier: uint } 
  { 
    originator: principal, 
    headline: (string-ascii 100), 
    hyperlink: (string-ascii 200), 
    topic: (string-ascii 20),
    publication-epoch: uint, 
    appraisals: int,
    gratuities: uint,
    flags: uint
  }
)

;; User voting history and preferences tracking
(define-map participant-appraisals 
  { participant: principal, item-identifier: uint } 
  { appraisal: int }
)

;; Community reputation and trust scoring system
(define-map participant-credibility
  { participant: principal }
  { metric: int }
)

;; PRIVATE UTILITY FUNCTIONS

;; Validates existence of content item in the registry
(define-private (item-exists (item-identifier uint))
  (is-some (map-get? curated-items { item-identifier: item-identifier }))
)

;; Filters out empty/null content entries for clean data retrieval
(define-private (not-none (item (optional {
    originator: principal, 
    headline: (string-ascii 100), 
    hyperlink: (string-ascii 200), 
    topic: (string-ascii 20),
    publication-epoch: uint, 
    appraisals: int,
    gratuities: uint,
    flags: uint
  })))
  (is-some item)
)

;; Quality gate filter - returns only positively rated content
(define-private (retrieve-item-if-valid (id uint))
  (match (map-get? curated-items { item-identifier: id })
    item (if (>= (get appraisals item) 0) (some item) none)
    none
  )
)

;; Generates bounded sequential identifier lists for batch operations
(define-private (enumerate (n uint))
  (let ((limit (if (> n u10) u10 n)))
    (list
      (if (>= limit u1) u1 u0)
      (if (>= limit u2) u2 u0)
      (if (>= limit u3) u3 u0)
      (if (>= limit u4) u4 u0)
      (if (>= limit u5) u5 u0)
      (if (>= limit u6) u6 u0)
      (if (>= limit u7) u7 u0)
      (if (>= limit u8) u8 u0)
      (if (>= limit u9) u9 u0)
      (if (>= limit u10) u10 u0)
    )
  )
)

;; Filters zero values from enumerated lists
(define-private (is-non-zero (n uint))
  (not (is-eq n u0))
)

;; PUBLIC CONTENT MANAGEMENT FUNCTIONS

;; Submit new content for community evaluation and curation
(define-public (contribute-item (headline (string-ascii 100)) (hyperlink (string-ascii 200)) (topic (string-ascii 20)))
  (let
    (
      (item-identifier (+ (var-get aggregate-submissions) u1))
    )
    ;; Input validation and security checks
    (asserts! (and 
                (>= (len headline) u1)
                (>= (len hyperlink) MIN_HYPERLINK_LENGTH)
                (>= (len topic) u1)
              ) ERR_INVALID_SUBMISSION)
    (asserts! (> item-identifier (var-get aggregate-submissions)) ERR_OVERFLOW)
    (asserts! (is-some (index-of (var-get content-topics) topic)) ERR_INVALID_TOPIC)
    (asserts! (>= (stx-get-balance tx-sender) (var-get submission-charge)) ERR_INADEQUATE_BALANCE)
    
    ;; Process submission fee payment
    (try! (stx-transfer? (var-get submission-charge) tx-sender PROTOCOL_ADMINISTRATOR))
    
    ;; Register new content item with metadata
    (map-set curated-items
      { item-identifier: item-identifier }
      {
        originator: tx-sender,
        headline: headline,
        hyperlink: hyperlink,
        topic: topic,
        publication-epoch: stacks-block-height,
        appraisals: 0,
        gratuities: u0,
        flags: u0
      }
    )
    
    ;; Update global submission counter
    (var-set aggregate-submissions item-identifier)
    
    ;; Emit submission event for indexing
    (print { type: "new-item", item-identifier: item-identifier, originator: tx-sender })
    (ok item-identifier)
  )
)

;; Community-driven content evaluation with reputation implications
(define-public (appraise-item (item-identifier uint) (appraisal int))
  (let
    (
      (previous-appraisal (default-to 0 (get appraisal (map-get? participant-appraisals { participant: tx-sender, item-identifier: item-identifier }))))
      (target-item (unwrap! (map-get? curated-items { item-identifier: item-identifier }) ERR_NONEXISTENT_ITEM))
      (appraiser-standing (default-to { metric: 0 } (map-get? participant-credibility { participant: tx-sender })))
    )
    ;; Validation checks
    (asserts! (item-exists item-identifier) ERR_NONEXISTENT_ITEM)
    (asserts! (or (is-eq appraisal 1) (is-eq appraisal -1)) ERR_INVALID_APPRAISAL)
    
    ;; Record user's evaluation
    (map-set participant-appraisals
      { participant: tx-sender, item-identifier: item-identifier }
      { appraisal: appraisal }
    )
    
    ;; Update content's aggregate score
    (map-set curated-items
      { item-identifier: item-identifier }
      (merge target-item { appraisals: (+ (get appraisals target-item) (- appraisal previous-appraisal)) })
    )
    
    ;; Adjust user's reputation based on participation
    (map-set participant-credibility
      { participant: tx-sender }
      { metric: (+ (get metric appraiser-standing) appraisal) }
    )
    
    ;; Emit evaluation event
    (print { type: "appraisal", item-identifier: item-identifier, appraiser: tx-sender, appraisal: appraisal })
    (ok true)
  )
)

;; Direct monetary rewards system for quality content creators
(define-public (reward-originator (item-identifier uint) (gratuity-amount uint))
  (let
    (
      (target-item (unwrap! (map-get? curated-items { item-identifier: item-identifier }) ERR_NONEXISTENT_ITEM))
    )
    ;; Validation and balance checks
    (asserts! (item-exists item-identifier) ERR_NONEXISTENT_ITEM)
    (asserts! (>= (stx-get-balance tx-sender) gratuity-amount) ERR_INADEQUATE_BALANCE)
    
    ;; Update gratuity tracking before transfer
    (map-set curated-items
      { item-identifier: item-identifier }
      (merge target-item { gratuities: (+ (get gratuities target-item) gratuity-amount) })
    )
    
    ;; Execute STX transfer to content creator
    (try! (stx-transfer? gratuity-amount tx-sender (get originator target-item)))
    
    ;; Emit reward event
    (print { type: "reward", item-identifier: item-identifier, from: tx-sender, to: (get originator target-item), amount: gratuity-amount })
    (ok true)
  )
)

;; Community moderation through content flagging mechanism
(define-public (flag-item (item-identifier uint))
  (let
    (
      (target-item (unwrap! (map-get? curated-items { item-identifier: item-identifier }) ERR_NONEXISTENT_ITEM))
    )
    ;; Validation checks
    (asserts! (item-exists item-identifier) ERR_NONEXISTENT_ITEM)
    (asserts! (not (is-eq (get originator target-item) tx-sender)) ERR_INVALID_FLAG)
    
    ;; Increment flag counter
    (map-set curated-items
      { item-identifier: item-identifier }
      (merge target-item { flags: (+ (get flags target-item) u1) })
    )
    
    ;; Emit flagging event
    (print { type: "flag", item-identifier: item-identifier, flagger: tx-sender })
    (ok true)
  )
)

;; READ-ONLY QUERY INTERFACE

;; Retrieve comprehensive content metadata by identifier
(define-read-only (retrieve-item-details (item-identifier uint))
  (map-get? curated-items { item-identifier: item-identifier })
)

;; Query user's evaluation history for specific content
(define-read-only (retrieve-participant-appraisal (participant principal) (item-identifier uint))
  (get appraisal (map-get? participant-appraisals { participant: participant, item-identifier: item-identifier }))
)

;; Get current total submissions in the protocol
(define-read-only (retrieve-aggregate-submissions)
  (var-get aggregate-submissions)
)

;; Access user's reputation and credibility metrics
(define-read-only (retrieve-participant-credibility (participant principal))
  (default-to { metric: 0 } (map-get? participant-credibility { participant: participant }))
)

;; Generate list of valid content identifiers
(define-read-only (get-item-ids (count uint))
  (filter is-non-zero (enumerate count))
)

;; Retrieve highest-rated content with pagination support
(define-read-only (retrieve-top-items (limit uint))
  (let
    (
      (item-count (var-get aggregate-submissions))
      (actual-limit (if (> limit item-count) item-count limit))
    )
    (filter not-none
      (map retrieve-item-if-valid (get-item-ids actual-limit))
    )
  )
)

;; ADMINISTRATIVE GOVERNANCE FUNCTIONS

;; Dynamic fee adjustment for protocol sustainability
(define-public (adjust-submission-charge (new-charge uint))
  (begin
    (asserts! (is-eq tx-sender PROTOCOL_ADMINISTRATOR) ERR_UNAUTHORIZED_ACCESS)
    (asserts! (<= new-charge MAX_UINT) ERR_OVERFLOW)
    (var-set submission-charge new-charge)
    (print { type: "fee-change", new-charge: new-charge })
    (ok true)
  )
)

;; Emergency content removal for policy violations
(define-public (expunge-item (item-identifier uint))
  (begin
    (asserts! (is-eq tx-sender PROTOCOL_ADMINISTRATOR) ERR_UNAUTHORIZED_ACCESS)
    (asserts! (item-exists item-identifier) ERR_NONEXISTENT_ITEM)
    (map-delete curated-items { item-identifier: item-identifier })
    (print { type: "item-expunged", item-identifier: item-identifier })
    (ok true)
  )
)

;; Expand content categorization system
(define-public (introduce-topic (new-topic (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender PROTOCOL_ADMINISTRATOR) ERR_UNAUTHORIZED_ACCESS)
    (asserts! (< (len (var-get content-topics)) u10) ERR_INVALID_TOPIC)
    (asserts! (>= (len new-topic) u1) ERR_INVALID_TOPIC)
    (var-set content-topics (unwrap-panic (as-max-len? (append (var-get content-topics) new-topic) u10)))
    (print { type: "new-topic", topic: new-topic })
    (ok true)
  )
)