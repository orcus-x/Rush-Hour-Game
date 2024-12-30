
# Rush Hour Game

A decentralized Rush Hour puzzle game developed in Solidity, designed to run on Web3. This project integrates blockchain technology with an interactive puzzle-solving experience.

## Features

- **Blockchain Integration**: Deployed using Solidity smart contracts.
- **Web3 Powered**: Interact with the Ethereum blockchain and other supported networks.
- **Puzzle Solver**: Provides automated puzzle-solving capabilities using smart contracts.
- **Multi-Network Support**: Compatible with Ethereum, Binance Smart Chain, and local testnets.

## Prerequisites

Before running the project, ensure you have the following installed:

- [Node.js](https://nodejs.org/)
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)
- [Metamask](https://metamask.io/) browser extension
- A private key with sufficient funds for deploying contracts.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/rush-hour-game.git
   cd rush-hour-game
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm start
   ```

   Open [http://localhost:3000](http://localhost:3000) in your browser.

## Usage

1. **Select a Blockchain Network**:
   - Choose from Ethereum Mainnet, BNB Smart Chain, or local testnets.

2. **Deploy Contract**:
   - Enter your private key and deploy the smart contract using the interface.

3. **Solve Puzzle**:
   - Input the puzzle configuration, and the app will call the smart contract's `solve` function.

## Project Structure

- **`RushHourPuzzle.js`**: Core component that handles contract deployment and interactions.
- **`App.js`**: Main application file.
- **Smart Contract**: Written in Solidity, handles the puzzle logic.

## Smart Contract

The contract includes:
- A function to solve the Rush Hour puzzle.
- Multi-directional movement support for solving configurations.

## Supported Chains

- **Ethereum Mainnet** 
- **BNB Smart Chain**
- **Local Testnets**

## Contributing

Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a new branch.
3. Make your changes and submit a pull request.

## Acknowledgements

- Solidity development and blockchain integration were inspired by modern decentralized applications.
- Built with [Create React App](https://github.com/facebook/create-react-app).
- Powered by [Web3.js](https://web3js.readthedocs.io/).