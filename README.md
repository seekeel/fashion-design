# Fashion Design IP Registry

A blockchain-based intellectual property registry smart contract for fashion design ownership and knockoff prevention, built on the Stacks blockchain using Clarity.

## Overview

The Fashion Design IP Registry is a decentralized solution that allows fashion designers to register their creative works, establish verifiable ownership, and create a transparent public registry to help prevent intellectual property theft and counterfeiting in the fashion industry.

## Features

- **Design Registration**: Register fashion designs with comprehensive metadata including name, description, category, and image hash
- **Ownership Verification**: Cryptographically verifiable proof of design ownership with timestamp
- **Unique Design Names**: Prevents duplicate design name registration across the registry
- **Ownership Transfer**: Transfer design ownership between principals with automatic record updates
- **Design Status Management**: Activate/deactivate designs while maintaining ownership records
- **Multi-Design Support**: Each designer can register up to 100 designs per account
- **IPFS Integration**: Support for IPFS content hashing for design images and assets
- **Transparent Registry**: Public read-only functions for design verification and lookup

## Technical Specifications

- **Blockchain**: Stacks
- **Smart Contract Language**: Clarity v2
- **Epoch**: 2.5
- **Maximum Designs per Owner**: 100
- **Design Name Length**: Up to 100 ASCII characters
- **Design Description Length**: Up to 500 ASCII characters
- **Category Length**: Up to 50 ASCII characters
- **Image Hash Length**: 64 characters (compatible with IPFS hashes)

## Project Structure

```
fashion-design/
├── README.md
└── fashion-design_contract/
    ├── Clarinet.toml
    ├── package.json
    ├── vitest.config.js
    ├── tsconfig.json
    ├── contracts/
    │   └── fashion-design.clar
    ├── tests/
    │   └── fashion-design.test.ts
    └── settings/
        ├── Devnet.toml
        ├── Testnet.toml
        └── Mainnet.toml
```

## Installation

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development tool
- [Node.js](https://nodejs.org/) (v16 or higher)
- [Git](https://git-scm.com/)

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd fashion-design
```

2. Install dependencies:
```bash
cd fashion-design_contract
npm install
```

3. Verify the installation:
```bash
clarinet check
```

## Usage Examples

### Registering a Design

```clarity
;; Register a new fashion design
(contract-call? .fashion-design register-design
    "Geometric Dress Pattern"
    "A unique geometric pattern for evening dresses featuring interlocking triangular motifs"
    "Evening Wear"
    "QmX4e8jS2kZ3aB7cF9dE1gH2iJ3kL4mN5oP6qR7sT8uV9w")
;; Returns: (ok u1) - the design ID
```

### Checking Design Availability

```clarity
;; Check if a design name is available
(contract-call? .fashion-design is-name-available "My Design Name")
;; Returns: true if available, false if taken
```

### Retrieving Design Information

```clarity
;; Get design details by ID
(contract-call? .fashion-design get-design u1)
;; Returns: design data including owner, name, description, etc.

;; Get design by name
(contract-call? .fashion-design get-design-by-name "Geometric Dress Pattern")
;; Returns: design ID if found
```

### Verifying Ownership

```clarity
;; Verify if a principal owns a specific design
(contract-call? .fashion-design verify-ownership u1 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)
;; Returns: true if the principal owns the design
```

### Transferring Design Ownership

```clarity
;; Transfer design to a new owner (must be called by current owner)
(contract-call? .fashion-design transfer-design u1 'ST2REHHS5J3CERCRBEPMGH7921Q6PYKAADT7JP2VB)
;; Returns: (ok true) on success
```

## Contract Functions

### Public Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `register-design` | name, description, category, image-hash | Register a new fashion design |
| `transfer-design` | design-id, new-owner | Transfer ownership of a design |
| `deactivate-design` | design-id | Deactivate a design (owner only) |
| `reactivate-design` | design-id | Reactivate a design (owner only) |

### Read-Only Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `get-design` | design-id | Get complete design information |
| `get-design-by-name` | name | Get design ID by name |
| `get-designs-by-owner` | owner | Get all design IDs owned by a principal |
| `is-name-available` | name | Check if design name is available |
| `get-next-design-id` | - | Get the next available design ID |
| `verify-ownership` | design-id, claimed-owner | Verify design ownership |
| `get-design-registration-time` | design-id | Get design registration timestamp |
| `is-design-active` | design-id | Check if design is active |

### Error Codes

- `u100`: Owner-only operation
- `u101`: Design name already exists
- `u102`: Design not found
- `u103`: Not the design owner
- `u104`: Invalid input parameters

## Testing

Run the test suite:

```bash
npm test
```

Run tests with coverage and cost analysis:

```bash
npm run test:report
```

Watch mode for continuous testing during development:

```bash
npm run test:watch
```

## Deployment Guide

### Devnet Deployment

1. Start the local devnet:
```bash
clarinet integrate
```

2. Deploy the contract:
```bash
clarinet deploy --devnet
```

### Testnet Deployment

1. Configure your testnet settings in `settings/Testnet.toml`
2. Deploy to testnet:
```bash
clarinet deploy --testnet
```

### Mainnet Deployment

1. Configure your mainnet settings in `settings/Mainnet.toml`
2. Ensure thorough testing on devnet and testnet
3. Deploy to mainnet:
```bash
clarinet deploy --mainnet
```

## Security Considerations

### Access Control
- Only design owners can transfer, activate, or deactivate their designs
- Design registration is open to all users
- No admin privileges or central authority control

### Data Integrity
- Design names must be unique across the entire registry
- All input parameters are validated for non-empty content
- Ownership records are immutable once recorded on-chain

### Design Limitations
- Maximum 100 designs per owner to prevent spam
- Design names limited to 100 ASCII characters
- Descriptions limited to 500 ASCII characters
- Categories limited to 50 ASCII characters

### Best Practices
- Store sensitive design files off-chain (e.g., IPFS) and only store hashes on-chain
- Verify design authenticity through multiple data points (name, description, image hash)
- Consider implementing additional verification mechanisms for high-value designs
- Regularly monitor design registrations for potential trademark conflicts

## Gas Optimization

The contract is optimized for gas efficiency:
- Uses efficient data structures (maps with appropriate key types)
- Minimal on-chain storage (stores hashes instead of full content)
- Batched operations where possible
- Read-only functions for data retrieval without gas costs

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes and add tests
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the ISC License.

## Support

For questions, issues, or contributions, please refer to the project's issue tracker or contact the development team.