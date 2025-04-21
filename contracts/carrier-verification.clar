;; carrier-verification.clar
;; This contract validates qualified refrigerated transporters

(define-data-var admin principal tx-sender)

;; Map to store verified carriers
(define-map verified-carriers principal
  {
    is-verified: bool,
    refrigeration-capability: (string-utf8 20),
    certification-expiry: uint,
    rating: uint
  }
)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-ALREADY-VERIFIED u101)
(define-constant ERR-NOT-VERIFIED u102)

;; Function to verify a carrier
(define-public (verify-carrier
    (carrier principal)
    (refrigeration-capability (string-utf8 20))
    (certification-expiry uint)
    (rating uint)
  )
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? verified-carriers carrier)) (err ERR-ALREADY-VERIFIED))
    (ok (map-set verified-carriers carrier {
      is-verified: true,
      refrigeration-capability: refrigeration-capability,
      certification-expiry: certification-expiry,
      rating: rating
    }))
  )
)

;; Function to revoke carrier verification
(define-public (revoke-verification (carrier principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-some (map-get? verified-carriers carrier)) (err ERR-NOT-VERIFIED))
    (ok (map-delete verified-carriers carrier))
  )
)

;; Function to check if a carrier is verified
(define-read-only (is-carrier-verified (carrier principal))
  (match (map-get? verified-carriers carrier)
    carrier-data (ok carrier-data)
    (err ERR-NOT-VERIFIED)
  )
)

;; Function to update admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set admin new-admin))
  )
)
