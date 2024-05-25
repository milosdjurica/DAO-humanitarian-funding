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
    Decentralized Autonomous Organization (DAO) with a single goal: to donate to individuals who lack the financial resources for medical treatment. Everyone deserves an equal chance, but unfortunately, that is not always the case. This DAO aims to address this issue by providing help to those in need.
    <br />
    <a href="https://github.com/milosdjurica/DAO-funding-foundry"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <!-- TODO -> put a sepolia network contract link in here, or Frontend -->
    <a href="https://github.com/milosdjurica/DAO-funding-foundry">View Demo</a>
    ·
    <a href="https://github.com/milosdjurica/DAO-funding-foundry/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    ·
    <a href="https://github.com/milosdjurica/DAO-funding-foundry/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
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
    </li>
     <li>
     <!-- TODO -> add those parts below -->
      <a href="#improvements">Improvements</a>
      <ul>
        <li><a href="#limitations">Limitations</a></li>
        <li><a href="#known-issues">Known Issues</a></li>
        <li><a href="#features">Features</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## About The Project

<!-- TODO -> Link to sepolia contract -->

[Deployed and verified contract on Sepolia testnet](https://example.com)

This project implements a decentralized governance system on the Ethereum blockchain, facilitated by a suite of smart contracts. It empowers token holders to participate in decision-making processes and provides mechanisms for funding individuals in need of medical treatment.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

- [Solidity v^0.8.20][Solidity-url]
- [Foundry][Foundry-url]
- [Chainlink Automation][Chainlink-automation-url]
- [Chainlink Verified Random Number Generator v2.0][Chainlink-verified-random-number-generator-url]
- [Openzeppelin Governance v5.x][Openzeppelin-governance-docs]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Technical Overview

<!-- TODO -> Add contracts overview and explain technically how it all works and connects together, who are owners what are privileges etc etc. Explain tests, deploy scripts. -->

#### Contracts:

<ol>
  <li>
    <strong>Funding Contract</strong>:
    <ul>
      <li>
        This contract holds funds and list of users that needs funding.
      </li>
      <li>
        DAO can add new users and update amount of funds that existing users need.
      </li>
      <li>
        Winner is picked automatically with Chainlink Automation, using Chainlink VRF in order to pick random winner.
      </li>
    </ul>

  </li>
  <li>
    <strong>VotingToken Contract</strong>:
    <ul>
      <li>This contract extends ERC20 functionality and integrates voting capabilities. Token holders use this token to vote on governance proposals.</li>
      <li>Contract is owned by TimeLock. Only TimeLock contract can mint new tokens (add new voters to DAO).</li>
    </ul>
  </li>
  <li>
    <strong>MyGovernor Contract</strong>:
    <ul>
      <li>A governance contract from the OpenZeppelin Contracts library.</li>
      <li>It enables token holders to vote on proposals, managing the governance process.</li>
    </ul>
  </li>
  <li>
    <strong>TimeLock Contract</strong>:
    <ul>
      <li>A time-lock mechanism built using OpenZeppelin's TimelockController.</li>
      <li>It acts as the owner of the Funding and VotingToken contracts and executes proposals passed by the MyGovernor contract.</li>
    </ul>
  </li>
</ol>

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

### Coverage

![Coverage image][Coverage-image-url]

<!-- TODO -> provide image of coverage and explain what was tested and how -->

### Disclaimer

Although code coverage is very high, this code has not been audited by professionals, so it is NOT SAFE FOR PRODUCTION. Milos Djurica holds NO responsibility for the provided code. This is just a personal project created for learning purposes only. It aims to one day provide a solution to the world's existing problem, but it should be audited by professionals first.

<!-- GETTING STARTED -->

## Getting Started

<!-- TODO -> Detailed instructions to clone, install foundry, install project dependencies, test, deploy, compile, etc... -->

### Prerequisites

1. Git
2. Foundry -> [Installation guide][Foundry-installation-guide-url]
   <!-- TODO -> add .env needed variables -->
   <!-- TODO -> Optional for fork testing -->
   <!-- TODO -> Optional for deploying on specific chains -->
   <!-- TODO -> Optional for verifying contracts ??? Not sure if need .env for this -->

### Installation

1. Clone the repo

```sh
 git clone https://github.com/milosdjurica/DAO-funding-foundry.git
```

2. Install dependencies

```sh
forge build
```

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

### Deploying

<!-- TODO -> FINISH DEPLOYING INSTRUCTIONS -->

1. 1. Get a free API Key at [https://example.com](https://example.com)

2. Fill out your `.env` variables
   ```js
   SEPOLIA_RPC_URL = "ENTER YOUR SEPOLIA API KEY";
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->

## Usage

To interact with the governance system, users can:

- Vote on proposals using VotingToken.
- Propose changes or actions through the MyGovernor contract.
- Monitor the funding distribution process through the Funding contract.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- IMPROVEMENTS -->

## Improvements

<!-- TODO -> Add improvements, Add known issues (bad voters, maybe too much voting power??? Check this!!!) and limitations(Automatization 2.0, limited to some chains, Doesn't allow other tokens, Add this in future plans). -->

### Limitations

### Known Issues

### Features

 <li><a href="#limitations">Limitations</a></li>

<!-- ROADMAP -->

## Roadmap

- [ ] Feature 1
- [ ] Feature 2
- [ ] Feature 3
  - [ ] Nested Feature

See the [open issues](https://github.com/milosdjurica/DAO-funding-foundry/issues) for a full list of proposed features (and known issues).

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

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->

## Contact

Milos Djurica - [linkedin.com/in/milosdjurica](https://linkedin.com/in/milosdjurica) - milosdjurica.work@gmail.com

Project Link: [https://github.com/milosdjurica/DAO-funding-foundry](https://github.com/milosdjurica/DAO-funding-foundry)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->

## Acknowledgments

- []()
- []()
- []()

<p align="right">(<a href="#readme-top">back to top</a>)</p>

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
