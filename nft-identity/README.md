# Digital Identity NFT Project

## Overview

This project implements a digital identity Non-Fungible Token (NFT) smart contract on the Stacks blockchain using Clarity smart contract language. The contract provides a secure and decentralized way to manage digital identities.

## Features

- Create and mint unique digital identity tokens
- Transfer digital identity tokens between principals
- Verify ownership of a digital identity token
- Administrative control with contract owner privileges

## Contract Functions

### `initialize()`
- Sets the contract deployer as the initial contract owner
- Can only be called once

### `mint-token(token-id, recipient)`
- Allows the contract owner to mint a new digital identity token
- Requires administrative privileges
- Creates a unique NFT with a specified token ID

### `transfer-token(token-id, new-owner)`
- Enables current token owners to transfer their digital identity token
- Validates the current owner before transfer

### `verify-identity(token-id, user)`
- Checks if a specific principal owns a given digital identity token
- Returns a boolean indicating ownership status

## Prerequisites

- Clarinet CLI
- Stacks blockchain development environment
- Basic understanding of Clarity smart contract development

## Setup

1. Clone the repository
```bash
git clone <your-repository-url>
cd nft-digital-identity
```

2. Install dependencies
```bash
npm install -g @stacks/cli
```

3. Verify the project
```bash
clarinet check
```

4. Run tests
```bash
clarinet test
```

5. Deploy locally
```bash
clarinet deploy
```

## Configuration

Customize `Clarinet.toml`:
- Update author information
- Replace mnemonic phrases
- Adjust account balances

## Error Codes

- `u100`: Contract already initialized
- `u101`: Unauthorized contract owner access
- `u102`: Invalid sender
- `u103`: Contract owner not set
- `u104`: Token transfer unauthorized

## Security Considerations

- Only the contract owner can mint tokens
- Token transfers are restricted to current owners
- Minimal administrative privileges

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information.
