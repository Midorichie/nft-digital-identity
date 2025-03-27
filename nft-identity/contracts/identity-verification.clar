;; Identity Verification Contract

;; Errors
(define-constant ERR-NOT-AUTHORIZED (err u2000))
(define-constant ERR-VERIFICATION-EXISTS (err u2001))
(define-constant ERR-INVALID-VERIFICATION (err u2002))

;; Import the digital identity contract
(use-trait digital-identity-trait .digital-identity.only-owner)

;; Verification status map
(define-map verifications 
  { 
    token-id: uint, 
    verifier: principal 
  } 
  {
    verified: bool,
    verification-timestamp: uint,
    verification-type: (string-ascii 50)
  }
)

;; Verification requests map
(define-map verification-requests 
  { 
    token-id: uint, 
    requester: principal 
  } 
  {
    requested-at: uint,
    verification-type: (string-ascii 50)
  }
)

;; Request verification for an identity token
(define-public (request-verification 
  (digital-identity-contract <digital-identity-trait>) 
  (token-id uint)
  (verification-type (string-ascii 50))
)
  (begin
    ;; Verify the requester owns the token
    (asserts! 
      (is-ok 
        (contract-call? digital-identity-contract verify-identity token-id tx-sender)
      ) 
      ERR-NOT-AUTHORIZED
    )
    
    ;; Create verification request
    (map-set verification-requests 
      { token-id: token-id, requester: tx-sender }
      {
        requested-at: block-height,
        verification-type: verification-type
      }
    )
    
    (ok true)
  )
)

;; Perform verification (only by authorized verifiers)
(define-public (verify-identity 
  (digital-identity-contract <digital-identity-trait>) 
  (token-id uint)
  (verification-type (string-ascii 50))
)
  (let 
    (
      (request 
        (unwrap! 
          (map-get? verification-requests 
            { token-id: token-id, requester: tx-sender }
          ) 
          ERR-INVALID-VERIFICATION
        )
      )
    )
    
    ;; Prevent duplicate verifications
    (asserts! 
      (is-none 
        (map-get? verifications 
          { token-id: token-id, verifier: tx-sender }
        )
      ) 
      ERR-VERIFICATION-EXISTS
    )
    
    ;; Store verification
    (map-set verifications 
      { token-id: token-id, verifier: tx-sender }
      {
        verified: true,
        verification-timestamp: block-height,
        verification-type: verification-type
      }
    )
    
    ;; Remove the verification request
    (map-delete verification-requests 
      { token-id: token-id, requester: tx-sender }
    )
    
    (ok true)
  )
)

;; Check verification status
(define-read-only (get-verification-status 
  (token-id uint) 
  (verifier principal)
)
  (map-get? verifications 
    { token-id: token-id, verifier: verifier }
  )
)
