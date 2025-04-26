;; EduStake - Scholarship Funding Platform
;; A platform where donors can stake STX to generate yields for student scholarships
;; with transparent tracking of fund allocation and scholarship distribution

;; Define data variables for contract
(define-data-var total-staked uint u0)
(define-data-var scholarship-pool uint u0)
(define-data-var admin principal tx-sender)

(define-map stakers principal 
  { 
    amount: uint,
    timestamp: uint,
    yield-claimed: uint
  }
)

(define-map scholarship-recipients principal 
  {
    total-awarded: uint,
    last-disbursement: uint,
    institution: (string-ascii 64),
    field-of-study: (string-ascii 64),
    active: bool
  }
)

;; Error codes
(define-constant ERR-NOT-ADMIN (err u101))
(define-constant ERR-ZERO-AMOUNT (err u102))
(define-constant ERR-NO-STAKE-FOUND (err u103))
(define-constant ERR-MIN-STAKING-PERIOD (err u104))
(define-constant ERR-RECIPIENT-EXISTS (err u105))
(define-constant ERR-RECIPIENT-NOT-FOUND (err u106))
(define-constant ERR-INSUFFICIENT-POOL (err u107))
(define-constant ERR-UNAUTHORIZED (err u108))

;; Admin functions

;; Set a new admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-ADMIN)
    (var-set admin new-admin)
    (ok true)
  )
)

;; Staking functions

;; Stake STX to support scholarships
(define-public (stake-stx (amount uint))
  (begin
    (asserts! (> amount u0) ERR-ZERO-AMOUNT)
    
    ;; Transfer STX from sender to contract
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    ;; Update staker info
    (match (map-get? stakers tx-sender)
      existing-stake 
      (map-set stakers tx-sender 
        {
          amount: (+ amount (get amount existing-stake)),
          timestamp: block-height,
          yield-claimed: (get yield-claimed existing-stake)
        }
      )
      (map-set stakers tx-sender 
        {
          amount: amount,
          timestamp: block-height,
          yield-claimed: u0
        }
      )
    )
    
    ;; Update total staked
    (var-set total-staked (+ (var-get total-staked) amount))
    
    (ok amount)
  )
)

;; Unstake STX (with minimum staking period of 30 days ~ 4320 blocks)
(define-public (unstake-stx (amount uint))
  (let (
    (staker-data (unwrap! (map-get? stakers tx-sender) ERR-NO-STAKE-FOUND))
    (staked-amount (get amount staker-data))
    (stake-time (get timestamp staker-data))
    (min-blocks u4320)  ;; approximately 30 days
  )
    ;; Check minimum staking period
    (asserts! (>= (- block-height stake-time) min-blocks) ERR-MIN-STAKING-PERIOD)
    
    ;; Ensure amount is valid
    (asserts! (<= amount staked-amount) ERR-ZERO-AMOUNT)
    
    ;; Calculate yield (simplified: 5% annual rate, prorated by blocks)
    (let (
      (blocks-staked (- block-height stake-time))
      (yearly-yield-rate u500)  ;; 5% represented as 500 basis points
      (blocks-per-year u52560)  ;; approximately 365 days
      (yield-amount (/ (* amount (* blocks-staked yearly-yield-rate)) (* blocks-per-year u10000)))
    )
      ;; Update staker data
      (if (is-eq amount staked-amount)
        (map-delete stakers tx-sender)
        (map-set stakers tx-sender 
          {
            amount: (- staked-amount amount),
            timestamp: block-height,
            yield-claimed: (+ (get yield-claimed staker-data) yield-amount)
          }
        )
      )
      
      ;; Update total staked
      (var-set total-staked (- (var-get total-staked) amount))
      
      ;; Update scholarship pool with yield
      (var-set scholarship-pool (+ (var-get scholarship-pool) yield-amount))
      
      ;; Transfer STX back to staker
      (as-contract (stx-transfer? amount tx-sender tx-sender))
      
      (ok true)
    )
  )
)

;; Scholarship management functions

;; Register a new scholarship recipient
(define-public (register-recipient 
  (recipient principal) 
  (institution (string-ascii 64)) 
  (field-of-study (string-ascii 64)))
  (begin 
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-ADMIN)
    (asserts! (is-none (map-get? scholarship-recipients recipient)) ERR-RECIPIENT-EXISTS)
    
    (map-set scholarship-recipients recipient 
      {
        total-awarded: u0,
        last-disbursement: u0,
        institution: institution,
        field-of-study: field-of-study,
        active: true
      }
    )
    
    (ok true)
  )
)

;; Award scholarship funds to a recipient
(define-public (award-scholarship (recipient principal) (amount uint))
  (let (
    (recipient-data (unwrap! (map-get? scholarship-recipients recipient) ERR-RECIPIENT-NOT-FOUND))
    (pool-balance (var-get scholarship-pool))
  )
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-ADMIN)
    (asserts! (get active recipient-data) ERR-RECIPIENT-NOT-FOUND)
    (asserts! (<= amount pool-balance) ERR-INSUFFICIENT-POOL)
    
    ;; Update recipient data
    (map-set scholarship-recipients recipient 
      {
        total-awarded: (+ (get total-awarded recipient-data) amount),
        last-disbursement: block-height,
        institution: (get institution recipient-data),
        field-of-study: (get field-of-study recipient-data),
        active: true
      }
    )
    
    ;; Update scholarship pool
    (var-set scholarship-pool (- pool-balance amount))
    
    ;; Transfer STX to recipient
    (as-contract (stx-transfer? amount tx-sender recipient))
    
    (ok true)
  )
)

;; Deactivate a scholarship recipient
(define-public (deactivate-recipient (recipient principal))
  (let (
    (recipient-data (unwrap! (map-get? scholarship-recipients recipient) ERR-RECIPIENT-NOT-FOUND))
  )
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-ADMIN)
    
    (map-set scholarship-recipients recipient 
      {
        total-awarded: (get total-awarded recipient-data),
        last-disbursement: (get last-disbursement recipient-data),
        institution: (get institution recipient-data),
        field-of-study: (get field-of-study recipient-data),
        active: false
      }
    )
    
    (ok true)
  )
)

;; Direct donation to scholarship pool (no staking)
(define-public (donate-to-pool (amount uint))
  (begin
    (asserts! (> amount u0) ERR-ZERO-AMOUNT)
    
    ;; Transfer STX from sender to contract
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    ;; Update scholarship pool
    (var-set scholarship-pool (+ (var-get scholarship-pool) amount))
    
    (ok true)
  )
)

;; Read-only functions

;; Get staking details for a principal
(define-read-only (get-staker-info (staker principal))
  (map-get? stakers staker)
)

;; Get scholarship recipient details
(define-read-only (get-recipient-info (recipient principal))
  (map-get? scholarship-recipients recipient)
)

;; Get platform statistics
(define-read-only (get-platform-stats)
  {
    total-staked: (var-get total-staked),
    scholarship-pool: (var-get scholarship-pool),
    admin: (var-get admin)
  }
)

;; Calculate potential yield for a staker
(define-read-only (calculate-potential-yield (staker principal))
  (match (map-get? stakers staker)
    existing-stake 
    (let (
      (amount (get amount existing-stake))
      (stake-time (get timestamp existing-stake))
      (blocks-staked (- block-height stake-time))
      (yearly-yield-rate u500)  ;; 5% represented as 500 basis points
      (blocks-per-year u52560)  ;; approximately 365 days
    )
      (ok (/ (* amount (* blocks-staked yearly-yield-rate)) (* blocks-per-year u10000)))
    )
    ERR-NO-STAKE-FOUND
  )
)