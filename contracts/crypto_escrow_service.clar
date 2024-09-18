;; crypto_escrow_service
;; This contract implements a simple escrow service. Users can create escrows, confirm receipt of goods, request refunds, and arbitrate disputes.

;; constants
;; Define constant values used throughout the contract

;; data maps and vars
(define-map escrow-contracts 
  {id: uint} ;; Unique identifier for each escrow
  {
    buyer: principal, ;; Buyer involved in the escrow
    seller: principal, ;; Seller involved in the escrow
    arbiter: principal, ;; Arbiter who can resolve disputes
    amount: uint, ;; Amount of STX held in escrow
    status: uint ;; Status of the escrow (0 = Open, 1 = Completed, 2 = Refunded)
  }
)

(define-data-var escrow-counter uint u1) ;; Counter to generate unique escrow IDs

;; private functions
;; Internal functions used within the contract

(define-private (get-escrow (id uint))
  (map-get? escrow-contracts {id: id}) ;; Retrieve escrow data based on ID
)

;; public functions
;; Functions accessible externally by contract users

(define-public (create-escrow (seller principal) (arbiter principal) (amount uint))
  (begin
    ;; Ensure the buyer has sufficient funds to cover the escrow amount
    (asserts! (>= (stx-get-balance tx-sender) amount) (err "Insufficient funds"))

    ;; Ensure the seller and arbiter are not the same as the buyer
    (asserts! (not (is-eq tx-sender seller)) (err "Buyer and seller cannot be the same"))
    (asserts! (not (is-eq tx-sender arbiter)) (err "Buyer and arbiter cannot be the same"))

    ;; Generate a new escrow ID and increment the counter
    (let ((new-id (var-get escrow-counter)))
      (var-set escrow-counter (+ new-id u1))

      ;; Store the escrow details in the map
      (map-set escrow-contracts {id: new-id}
        {
          buyer: tx-sender, ;; Address of the buyer (current transaction sender)
          seller: seller, ;; Address of the seller
          arbiter: arbiter, ;; Address of the arbiter
          amount: amount, ;; Amount of STX held in escrow
          status: u0 ;; Status set to Open (0)
        }
      )
      (ok new-id) ;; Return the new escrow ID
    )
  )
)

(define-public (confirm-receipt (id uint))
  (let ((escrow-data (unwrap! (get-escrow id) (err u404)))) ;; Retrieve escrow data
    (begin
      ;; Ensure only the buyer can confirm receipt
      (asserts! (is-eq tx-sender (get buyer escrow-data)) (err u1)) ;; Error if the sender is not the buyer

      ;; Ensure the escrow status is Open before confirming receipt
      (asserts! (is-eq (get status escrow-data) u0) (err u10)) ;; Error if status is not Open

      ;; Transfer funds to the seller
      (match (stx-transfer? (get amount escrow-data) tx-sender (get seller escrow-data))
        success (begin
          ;; Update the escrow status to Completed (1)
          (map-set escrow-contracts {id: id} 
            (merge escrow-data {status: u1})
          )
          (ok true) ;; Return true to indicate success
        )
        error (err u2) ;; Error if the transfer fails
      )
    )
  )
)

(define-public (request-refund (id uint))
  (let ((escrow-data (unwrap! (get-escrow id) (err u404)))) ;; Retrieve escrow data
    (begin
      ;; Ensure only the buyer can request a refund
      (asserts! (is-eq tx-sender (get buyer escrow-data)) (err u4)) ;; Error if the sender is not the buyer

      ;; Ensure the escrow status is Open before requesting a refund
      (asserts! (is-eq (get status escrow-data) u0) (err u11)) ;; Error if status is not Open

      ;; Refund funds to the buyer
      (match (stx-transfer? (get amount escrow-data) tx-sender (get buyer escrow-data))
        success (begin
          ;; Update the escrow status to Refunded (2)
          (map-set escrow-contracts {id: id}
            (merge escrow-data {status: u2})
          )
          (ok true) ;; Return true to indicate success
        )
        error (err u5) ;; Error if the transfer fails
      )
    )
  )
)