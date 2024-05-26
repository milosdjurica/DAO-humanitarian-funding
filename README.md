<a name="readme-top"></a>

<!-- TODO -> Fix those links -->

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <!-- <a href="https://github.com/milosdjurica/DAO-funding-foundry">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a> -->

<h3 align="center">Humanitarian DAO</h3>

  <p align="center">
    Decentralized Autonomous Organization (DAO) with a goal to donate to individuals who lack the financial resources for medical treatment. Everyone deserves an equal chance, but unfortunately, that is not always the case. This DAO aims to address this issue by providing help to those in need.
    <br />
    <a href="https://github.com/milosdjurica/DAO-funding-foundry"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://sepolia.etherscan.io/address/0x939b6eab56e536a3cc991ade5ae22888e68417c2">View Funding Contract</a>
    ·
    <a href="https://github.com/milosdjurica/DAO-funding-foundry/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    ·
    <a href="https://github.com/milosdjurica/DAO-funding-foundry/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->

## Table of Contents

  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
        <li><a href="#technical-overview">Technical overview</a></li>
        <li><a href="#coverage">Coverage</a></li>
        <li><a href="#disclaimer">Disclaimer</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
          <li><a href="#testing">Testing</a></li>
          <li><a href="#deploying">Deploying</a></li>
      </ul>
    </li>
    <li>
      <a href="#usage">Usage</a>
      <ul>
        <li><a href="#examples">Examples</a></li>
      </ul>
    </li>
     <li>
      <a href="#improvements">Improvements</a>
      <ul>
        <li><a href="#limitations">Limitations</a></li>
        <li><a href="#known-issues">Known Issues</a></li>
        <li><a href="#features">Features</a></li>
      </ul>
    </li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <!-- <li><a href="#acknowledgments">Acknowledgments</a></li> -->
  </ol>

<!-- ABOUT THE PROJECT -->

## About The Project

Project implements a decentralized governance system with smart contracts deployed and verified on Sepolia Testnet. This DAO is created to provide financial help to individuals who lack resources for a medical treatment. Token holders (voters) can vote to add new voters, add new users that need help and adjust amount that those users need.

### Contracts are deployed and verified on Sepolia Testnet:

- [`VotingToken`][VotingToken-sepolia-url]
- [`TimeLock`][TimeLock-sepolia-url]
- [`MyGovernor`][MyGovernor-sepolia-url]
- [`Funding`][Funding-sepolia-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

- [Solidity v^0.8.20][Solidity-url]
- [Foundry][Foundry-url]
- [Chainlink Automation][Chainlink-automation-url]
- [Chainlink Verified Random Number Generator v2.0][Chainlink-verified-random-number-generator-url]
- [Openzeppelin Governance v5.x][Openzeppelin-governance-docs]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Technical Overview

#### Contracts:

1.  `Funding` Contract:

    - This contract holds funds and list of users that needs funding.
    - DAO can add new users and update amount of funds that existing users need.
    - Winner is picked automatically with Chainlink Automation, using Chainlink VRF in order to pick random winner.

2.  `VotingToken` Contract:

    - This contract extends ERC20 functionality and integrates voting capabilities. Token holders use this token to vote on governance proposals.
    - Contract is owned by `TimeLock`. Only `TimeLock` contract can mint new tokens (add new voters to DAO).

3.  `MyGovernor` Contract:

    - A governance contract from the OpenZeppelin Contracts library.
    - It enables token holders to vote on proposals, managing the governance process.

4.  `TimeLock` Contract:

    - A time-lock mechanism built using OpenZeppelin's `TimelockController`.
    - It acts as the OWNER of the `Funding` and `VotingToken` contracts and executes proposals passed by the `MyGovernor` contract.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

#### Dependencies

<ol>
  <li>
    <strong>OpenZeppelin Contracts</strong>:
    <ul>
      <li>Integrated for secure and audited smart contracts for DAO management.</li>
    </ul>
  </li>
  <li>
    <strong>Chainlink VRF</strong>:
    <ul>
      <li>Integrated for randomness generation for picking the winner.</li>
    </ul>
  </li>
  <li>
    <strong>Chainlink Automation</strong>:
    <ul>
      <li>Integrated for automatically picking the winner and funding them.</li>
    </ul>
  </li>
</ol>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Coverage

#### Tests ->

- Total number of 54 tests
- Unit tests
- Integration tests
- Fuzz tests

#### Coverage % ->

- Lines -> 97.83% (90/92)
- Statements -> 95.16% (118/124)
- Branches -> 92.86% (26/28)
- Functions -> 84.85% (28/33)

![Coverage image][Coverage-image-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Disclaimer

Although code coverage is very high, this code has not been audited by professionals, so it is NOT SAFE FOR PRODUCTION. Milos Djurica holds NO responsibility for the provided code. This is just a personal project created for learning purposes only. It aims to one day provide a solution to the world's existing problem, but it should be audited by professionals first.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->

## Getting Started

### Prerequisites

1. Git
2. Foundry -> [Installation guide][Foundry-installation-guide-url]
3. Get a free API Key for RPC requests at [Alchemy][Alchemy-url]. For fork testing and deploying
4. Get a free API Key for verifying contracts at [Etherscan][Etherscan-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Installation

1. Clone the repo

```sh
 git clone https://github.com/milosdjurica/DAO-funding-foundry.git
```

2. Install dependencies

```sh
forge build
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Testing

1. Run tests

```sh
forge test
```

2. Run only Unit tests

```sh
forge test --mc Unit
```

3. Run only Fuzz tests

```sh
forge test --mc Fuzz
```

4. Run tests with more details (logs) -> [Foundry Docs][Foundry-logs-docs-url]

```sh
forge test -vvv
```

5. See coverage

```sh
forge coverage
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Deploying

<!-- TODO -> FINISH DEPLOYING INSTRUCTIONS -->

1. Get a free API Key for RPC requests at [Alchemy][Alchemy-url]
2. Get a free API Key for verifying contracts at [Etherscan][Etherscan-url]

3. Fill out your `.env` variables
   ```js
   SEPOLIA_RPC_URL = "ENTER YOUR SEPOLIA API KEY";
   PRIVATE_KEY = "YOUR PRIVATE KEY";
   ETHERSCAN_API_KEY = "ENTER YOUR ETHERSCAN API KEY TO VERIFY CONTRACTS";
   ```
4. Load your .env variables in terminal

   ```
   source .env
   ```

5. Deploy and verify contracts

   ```
   forge script script/DeployAndSetUpContracts.s.sol:DeployAndSetUpContracts --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --etherscan-api-key $ETHERSCAN_API_KEY --verify
   ```

6. Register Chainlink Automation at -> https://automation.chain.link/
7. Register Chainlink at -> https://vrf.chain.link/

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->

## Usage

To interact with the governance system, users can:

- Vote on proposals using `VotingToken`.
- Propose changes or actions through the `MyGovernor` contract.
- Monitor the funding distribution process through the Funding contract.
- `TimeLock` is owner of `VotingToken` and `Funding` contracts. After proposal has passed, `TimeLock` contract is the one that executes those proposals.

### Examples

Write an example here:

1. **Giving voting power to new user**:

   1. Someone proposes new user to be added as a voter
   2. Voters vote on proposal on `MyGovernor` contract
   3. If proposal has passed, `TimeLock` contracts executes it and mints `VotingToken`s to the new user.

2. **Adding new user to be funded**:
   1. Someone proposes new user to be funded
   2. Voters vote on proposal on `MyGovernor` contract
   3. If proposal has passed, `TimeLock` contracts executes it and adds new user to array of users that need help in `Funding` contract.
   4. After required time has passed, `Chainlink Automation` and `Chainlink VRF` automatically and randomly pick a winner that gets the funds that are held by `Funding` smart contract

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- IMPROVEMENTS -->

## Improvements

### Limitations

- Chain limitation - because of VRF and Automation
- Works only with VRF subscription 2.0 version

### Known Issues

- Malicious voters

### Features

- Add support for ERC20 tokens, not just native ETH currency

### See the [open issues](https://github.com/milosdjurica/DAO-funding-foundry/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->

## License

Distributed under the MIT License. See `LICENSE` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->

## Contact

Milos Djurica - [linkedin.com/in/milosdjurica](https://linkedin.com/in/milosdjurica) - milosdjurica.work@gmail.com

Project Link: [https://github.com/milosdjurica/DAO-funding-foundry](https://github.com/milosdjurica/DAO-funding-foundry)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->

<!-- ## Acknowledgments

- []()
- []()
- []()

<p align="right">(<a href="#readme-top">back to top</a>)</p> -->

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/milosdjurica/DAO-funding-foundry.svg?style=for-the-badge
[contributors-url]: https://github.com/milosdjurica/DAO-funding-foundry/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/milosdjurica/DAO-funding-foundry.svg?style=for-the-badge
[forks-url]: https://github.com/milosdjurica/DAO-funding-foundry/network/members
[stars-shield]: https://img.shields.io/github/stars/milosdjurica/DAO-funding-foundry.svg?style=for-the-badge
[stars-url]: https://github.com/milosdjurica/DAO-funding-foundry/stargazers
[issues-shield]: https://img.shields.io/github/issues/milosdjurica/DAO-funding-foundry.svg?style=for-the-badge
[issues-url]: https://github.com/milosdjurica/DAO-funding-foundry/issues
[license-shield]: https://img.shields.io/github/license/milosdjurica/DAO-funding-foundry.svg?style=for-the-badge
[license-url]: https://github.com/milosdjurica/DAO-funding-foundry/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/milosdjurica
[product-screenshot]: images/screenshot.png
[Solidity-url]: https://soliditylang.org/
[Foundry-url]: https://book.getfoundry.sh/
[Chainlink-automation-url]: https://dev.chain.link/products/automation
[Chainlink-verified-random-number-generator-url]: https://dev.chain.link/products/vrf
[Openzeppelin-governance-docs]: https://docs.openzeppelin.com/contracts/5.x/governance
[Foundry-installation-guide-url]: https://book.getfoundry.sh/getting-started/installation
[Coverage-image-url]: https://github.com/milosdjurica/DAO-funding-foundry/blob/main/public/coverage.png
[Foundry-logs-docs-url]: https://book.getfoundry.sh/forge/tests?highlight=-vvv#logs-and-traces
[VotingToken-sepolia-url]: https://sepolia.etherscan.io/address/0xc0ba5577609989f2cbb0efdf256a88be07d54455
[TimeLock-sepolia-url]: https://sepolia.etherscan.io/address/0x09f8642c3fd71d3a46d620861104ceba180e9f71
[MyGovernor-sepolia-url]: https://sepolia.etherscan.io/address/0xa40ee7dd9a992f1a246a42296c8862172b549885
[Funding-sepolia-url]: https://sepolia.etherscan.io/address/0x939b6eab56e536a3cc991ade5ae22888e68417c2
[Alchemy-url]: https://www.alchemy.com/
[Etherscan-url]: https://docs.etherscan.io/getting-started/viewing-api-usage-statistics
