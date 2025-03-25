;; Digital Identity NFT Contract

;; Define a non-fungible token for digital identity
(define-non-fungible-token digital-identity-token uint)

;; Storage for the contract owner (for administrative actions)
(define-data-var contract-owner (optional principal) none)

;; Initialization function: set the deployer as the owner
(define-public (initialize)
  (if (is-none (var-get contract-owner))
      (begin 
        (var-set contract-owner (some tx-sender))
        (ok true)
      )
      (err u100)
  )
)

;; Mint a new digital identity NFT with a unique id.
(define-public (mint-token (token-id uint) (recipient principal))
  (let ((owner (var-get contract-owner)))
    (if (is-some owner)
        (if (is-eq tx-sender (unwrap! owner (err u101)))
            (begin
              (try! (nft-mint? digital-identity-token token-id recipient))
              (ok token-id)
            )
            (err u102)
        )
        (err u103)
    )
  )
)

;; Transfer token from current owner to a new owner
(define-public (transfer-token (token-id uint) (new-owner principal))
  (if (is-eq (nft-get-owner? digital-identity-token token-id) (some tx-sender))
      (begin
        (try! (nft-transfer? digital-identity-token token-id tx-sender new-owner))
        (ok token-id)
      )
      (err u104)
  )
)

;; Verify if a given principal holds a digital identity token
(define-read-only (verify-identity (token-id uint) (user principal))
  (is-eq (nft-get-owner? digital-identity-token token-id) (some user))
)
