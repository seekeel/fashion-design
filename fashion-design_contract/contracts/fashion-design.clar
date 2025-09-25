
;; title: fashion-design
;; version: 1.0.0
;; summary: IP registry smart contract for fashion design ownership and knockoff prevention
;; description: This contract allows fashion designers to register their designs,
;;              establish ownership, and provide a transparent registry to prevent knockoffs.

;; traits
;;

;; token definitions
;;

;; constants
;;
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-design-exists (err u101))
(define-constant err-design-not-found (err u102))
(define-constant err-not-owner (err u103))
(define-constant err-invalid-input (err u104))

;; data vars
;;
(define-data-var next-design-id uint u1)

;; data maps
;;
;; Main registry mapping design ID to design details
(define-map designs
    uint
    {
        owner: principal,
        name: (string-ascii 100),
        description: (string-ascii 500),
        category: (string-ascii 50),
        image-hash: (string-ascii 64), ;; IPFS hash or other content hash
        registration-time: uint,
        is-active: bool
    }
)

;; Secondary index: design name to design ID for uniqueness checking
(define-map design-names (string-ascii 100) uint)

;; Owner to design IDs mapping for easy lookup
(define-map owner-designs principal (list 100 uint))

;; public functions
;;

;; Register a new fashion design
(define-public (register-design (name (string-ascii 100))
                               (description (string-ascii 500))
                               (category (string-ascii 50))
                               (image-hash (string-ascii 64)))
    (let ((design-id (var-get next-design-id)))
        ;; Check if design name already exists
        (asserts! (is-none (map-get? design-names name)) err-design-exists)

        ;; Validate inputs
        (asserts! (> (len name) u0) err-invalid-input)
        (asserts! (> (len description) u0) err-invalid-input)
        (asserts! (> (len category) u0) err-invalid-input)
        (asserts! (> (len image-hash) u0) err-invalid-input)

        ;; Create the design entry
        (map-set designs design-id {
            owner: tx-sender,
            name: name,
            description: description,
            category: category,
            image-hash: image-hash,
            registration-time: block-height,
            is-active: true
        })

        ;; Set design name mapping
        (map-set design-names name design-id)

        ;; Update owner's design list
        (let ((current-designs (default-to (list) (map-get? owner-designs tx-sender))))
            (map-set owner-designs tx-sender (unwrap! (as-max-len? (append current-designs design-id) u100) err-invalid-input))
        )

        ;; Increment next design ID
        (var-set next-design-id (+ design-id u1))

        ;; Return the new design ID
        (ok design-id)
    )
)

;; Transfer ownership of a design
(define-public (transfer-design (design-id uint) (new-owner principal))
    (let ((design-data (unwrap! (map-get? designs design-id) err-design-not-found)))
        ;; Check if caller is the current owner
        (asserts! (is-eq tx-sender (get owner design-data)) err-not-owner)

        ;; Update design ownership
        (map-set designs design-id (merge design-data { owner: new-owner }))

        ;; Update old owner's design list
        (let ((old-designs (default-to (list) (map-get? owner-designs tx-sender))))
            (map-set owner-designs tx-sender (filter is-not-design-id old-designs))
        )

        ;; Update new owner's design list
        (let ((new-designs (default-to (list) (map-get? owner-designs new-owner))))
            (map-set owner-designs new-owner (unwrap! (as-max-len? (append new-designs design-id) u100) err-invalid-input))
        )

        (ok true)
    )
)

;; Deactivate a design (only owner can do this)
(define-public (deactivate-design (design-id uint))
    (let ((design-data (unwrap! (map-get? designs design-id) err-design-not-found)))
        ;; Check if caller is the owner
        (asserts! (is-eq tx-sender (get owner design-data)) err-not-owner)

        ;; Update design to inactive
        (map-set designs design-id (merge design-data { is-active: false }))

        (ok true)
    )
)

;; Reactivate a design (only owner can do this)
(define-public (reactivate-design (design-id uint))
    (let ((design-data (unwrap! (map-get? designs design-id) err-design-not-found)))
        ;; Check if caller is the owner
        (asserts! (is-eq tx-sender (get owner design-data)) err-not-owner)

        ;; Update design to active
        (map-set designs design-id (merge design-data { is-active: true }))

        (ok true)
    )
)

;; read only functions
;;

;; Get design details by ID
(define-read-only (get-design (design-id uint))
    (map-get? designs design-id)
)

;; Get design ID by name
(define-read-only (get-design-by-name (name (string-ascii 100)))
    (map-get? design-names name)
)

;; Get all designs owned by a principal
(define-read-only (get-designs-by-owner (owner principal))
    (map-get? owner-designs owner)
)

;; Check if a design name is available
(define-read-only (is-name-available (name (string-ascii 100)))
    (is-none (map-get? design-names name))
)

;; Get the next design ID that will be assigned
(define-read-only (get-next-design-id)
    (var-get next-design-id)
)

;; Verify design ownership
(define-read-only (verify-ownership (design-id uint) (claimed-owner principal))
    (match (map-get? designs design-id)
        design-data (is-eq (get owner design-data) claimed-owner)
        false
    )
)

;; Get design registration timestamp
(define-read-only (get-design-registration-time (design-id uint))
    (match (map-get? designs design-id)
        design-data (some (get registration-time design-data))
        none
    )
)

;; Check if design is active
(define-read-only (is-design-active (design-id uint))
    (match (map-get? designs design-id)
        design-data (get is-active design-data)
        false
    )
)

;; private functions
;;

;; Helper function for filtering design IDs (used in transfer function)
(define-private (is-not-design-id (id uint))
    (not (is-eq id (var-get next-design-id)))
)

