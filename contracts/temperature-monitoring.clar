;; temperature-monitoring.clar
;; This contract tracks environmental conditions during transit

(define-data-var admin principal tx-sender)

;; Map to store temperature readings
(define-map temperature-readings (tuple (shipment-id uint) (timestamp uint))
  {
    temperature: int,
    humidity: uint,
    reported-by: principal,
    location: (string-utf8 50)
  }
)

;; Map to store the latest reading for each shipment
(define-map latest-readings uint uint)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-READING-NOT-FOUND u101)

;; Function to record a temperature reading
(define-public (record-temperature
    (shipment-id uint)
    (temperature int)
    (humidity uint)
    (location (string-utf8 50))
  )
  (let ((timestamp block-height))
    (map-set temperature-readings (tuple (shipment-id shipment-id) (timestamp timestamp)) {
      temperature: temperature,
      humidity: humidity,
      reported-by: tx-sender,
      location: location
    })
    (map-set latest-readings shipment-id timestamp)
    (ok timestamp)
  )
)

;; Function to get a specific temperature reading
(define-read-only (get-temperature-reading (shipment-id uint) (timestamp uint))
  (match (map-get? temperature-readings (tuple (shipment-id shipment-id) (timestamp timestamp)))
    reading (ok reading)
    (err ERR-READING-NOT-FOUND)
  )
)

;; Function to get the latest reading for a shipment
(define-read-only (get-latest-reading (shipment-id uint))
  (match (map-get? latest-readings shipment-id)
    timestamp (get-temperature-reading shipment-id timestamp)
    (err ERR-READING-NOT-FOUND)
  )
)

;; Function to update admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-AUTHORIZED))
    (ok (var-set admin new-admin))
  )
)
