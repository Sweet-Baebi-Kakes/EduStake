# EduStake: Decentralized Scholarship Funding Platform

![EduStake Logo](https://via.placeholder.com/150x150.png?text=EduStake)

EduStake is a decentralized scholarship funding platform built on the Stacks blockchain that allows donors to stake STX tokens to generate yield for educational scholarships.

## Overview

EduStake creates a sustainable funding model for education by leveraging blockchain technology to provide transparent, efficient, and community-driven scholarships. Donors stake their STX tokens, generating yield that is allocated to verified scholarship recipients, while maintaining full ownership of their principal investment.

## Features

- **Yield-Generating Staking**: Stake STX tokens to generate yield for scholarships (5% annualized)
- **Transparent Fund Management**: All staking and scholarship distribution is tracked on-chain
- **Verified Recipients**: Educational institutions and students are verified before receiving funds
- **Minimum Staking Period**: 30-day minimum staking period ensures stability
- **Direct Donations**: Option to donate directly to the scholarship pool without staking
- **Scholarship Administration**: Managed distribution of funds to qualified students

## Smart Contract Functions

### Staking Functions

- `stake-stx`: Stake STX tokens to support scholarships
- `unstake-stx`: Withdraw staked STX after minimum staking period
- `donate-to-pool`: Make a direct donation to the scholarship pool

### Scholarship Management

- `register-recipient`: Register a new scholarship recipient with institutional information
- `award-scholarship`: Transfer scholarship funds to an approved recipient
- `deactivate-recipient`: Deactivate a recipient if they no longer qualify

### Read-Only Functions

- `get-staker-info`: Retrieve staking details for an address
- `get-recipient-info`: Get information about a scholarship recipient
- `get-platform-stats`: View platform-wide statistics
- `calculate-potential-yield`: Calculate potential yield for a staker

## Technical Implementation

The platform is implemented as a Clarity smart contract on the Stacks blockchain, leveraging the security and transparency of blockchain technology while providing a user-friendly interface for donors and recipients.

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) for local development and testing
- [Stacks Wallet](https://www.hiro.so/wallet) for interacting with the deployed contract

### Development Setup

1. Clone this repository
2. Install Clarinet following the [official guide](https://docs.hiro.so/smart-contracts/clarinet)
3. Run `clarinet check` to verify the contract
4. Run `clarinet test` to execute test cases

## Deployment

To deploy the EduStake contract to the Stacks testnet or mainnet:

1. Build the contract using Clarinet
2. Deploy using the Stacks transaction builder
3. Initialize the contract by setting initial parameters

## Roadmap

- **Q2 2025**: Launch beta version on Stacks testnet
- **Q3 2025**: Integration with educational institution verification systems
- **Q4 2025**: Mainnet launch with initial scholarship partnerships
- **Q1 2026**: Expansion to include learning achievement incentives

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

Project Link: [https://github.com/Sweet-Baebi-Kakes/EduStake.git](https://github.com/Sweet-Baebi-Kakes/EduStake.git)
