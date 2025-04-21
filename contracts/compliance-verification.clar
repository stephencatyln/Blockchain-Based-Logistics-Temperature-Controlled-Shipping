;; compliance-verification.clar
;; This contract ensures temperature maintenance throughout journey

(define-data-var admin principal tx-sender)

;; Map to store compliance status for shipments
(define-map compliance-status uint
  {
    is-compliant: bool,
    violations: uint,
    last-checked: uint,
    verified-by: principal
  }
)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-SHIPMENT-NOT-FOUND u101)

;; Function to verify compliance
(define-public (verify-compliance
    (shipment-id uint)
    (is-compliant bool)
    (violations uint)
  )
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (ok (map-set compliance-status shipment-id {
      is-compliant: is-compliant,
      violations: violations,
      last-checked: block-height,
      verified-by: tx-sender
    }))
  )
)

;; Function to get compliance status
(define-read-only (get-compliance-status (shipment-id uint))
  (match (map-get? compliance-status shipment-id)
    status (ok status)
    (err ERR-SHIPMENT-NOT-FOUND)
  )
)

;; Function to check if a shipment is compliant
(define-read-only (is-shipment-compliant (shipment-id uint))
  (match (map-get? compliance-status shipment-id)
    status (ok (get is-compliant status))
    (err ERR-SHIPMENT-NOT-FOUND)
  )
)

;; Function to update admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set admin new-admin))
  )
)
