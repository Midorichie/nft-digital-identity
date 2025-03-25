;; Enhanced Digital Identity NFT Contract

;; Errors
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-ALREADY-INITIALIZED (err u1001))
(define-constant ERR-INVALID-TOKEN (err u1002))
(define-constant ERR-TOKEN-ALREADY-EXISTS (err u1003))

;; Only owner trait
(define-trait only-owner
  (
    (check-owner (principal) (response bool uint))
    (verify-identity (uint principal) (response bool uint))
  )
)

;; Define a non-fungible token for digital identity
(define-non-fungible-token digital-identity-token uint)

;; Storage for the contract owner (for administrative actions)
(define-data-var contract-owner principal tx-sender)

;; Track minted tokens to prevent duplicates
(define-map minted-tokens uint bool)

;; Metadata storage for identity tokens
(define-map identity-metadata 
  uint 
  {
    created-at: uint,
    updated-at: uint,
    metadata-uri: (string-ascii 256)
  }
)

;; Ensure only the contract owner can call certain functions
(define-private (is-contract-owner (sender principal))
  (is-eq sender (var-get contract-owner))
)

;; Check owner implementation for trait
(define-public (check-owner (sender principal))
  (ok (is-contract-owner sender))
)

;; Mint a new digital identity NFT with enhanced checks
(define-public (mint-token 
  (token-id uint) 
  (recipient principal)
  (metadata-uri (string-ascii 256))
)
  (begin
    ;; Prevent duplicate token minting
    (asserts! (map-insert minted-tokens token-id true) ERR-TOKEN-ALREADY-EXISTS)
    
    ;; Ensure only contract owner can mint
    (asserts! (is-contract-owner tx-sender) ERR-NOT-AUTHORIZED)
    
    ;; Mint the NFT
    (try! (nft-mint? digital-identity-token token-id recipient))
    
    ;; Store metadata
    (map-set identity-metadata token-id {
      created-at: block-height,
      updated-at: block-height,
      metadata-uri: metadata-uri
    })
    
    (ok token-id)
  )
)

;; Verify if a given principal holds a digital identity token
(define-public (verify-identity (token-id uint) (user principal))
  (ok (is-eq (nft-get-owner? digital-identity-token token-id) (some user)))
)

;; Rest of the contract remains the same as in the previous version...
(define-public (transfer-contract-ownership (new-owner principal))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR-NOT-AUTHORIZED)
    (var-set contract-owner new-owner)
    (ok true)
  )
)

;; Enhanced transfer with additional checks
(define-public (transfer-token 
  (token-id uint) 
  (new-owner principal)
)
  (begin
    ;; Verify current ownership
    (asserts! 
      (is-eq (nft-get-owner? digital-identity-token token-id) (some tx-sender)) 
      ERR-NOT-AUTHORIZED
    )
    
    ;; Transfer the token
    (try! (nft-transfer? digital-identity-token token-id tx-sender new-owner))
    
    ;; Update metadata
    (map-set identity-metadata token-id 
      (merge 
        (unwrap! (map-get? identity-metadata token-id) ERR-INVALID-TOKEN)
        { updated-at: block-height }
      )
    )
    
    (ok token-id)
  )
)

;; Get token metadata
(define-read-only (get-token-metadata (token-id uint))
  (map-get? identity-metadata token-id)
)

;; Burn a token (with strict access control)
(define-public (burn-token (token-id uint))
  (begin
    ;; Verify ownership
    (asserts! 
      (is-eq (nft-get-owner? digital-identity-token token-id) (some tx-sender)) 
      ERR-NOT-AUTHORIZED
    )
    
    ;; Burn the token
    (try! (nft-burn? digital-identity-token token-id tx-sender))
    
    ;; Remove metadata
    (map-delete identity-metadata token-id)
    
    ;; Mark as no longer minted
    (map-delete minted-tokens token-id)
    
    (ok token-id)
  )
)
