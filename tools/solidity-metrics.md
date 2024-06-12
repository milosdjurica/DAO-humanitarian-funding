
[<img width="200" alt="get in touch with Consensys Diligence" src="https://user-images.githubusercontent.com/2865694/56826101-91dcf380-685b-11e9-937c-af49c2510aa0.png">](https://consensys.io/diligence)<br/>
<sup>
[[  🌐  ](https://consensys.io/diligence)  [  📩  ](mailto:diligence@consensys.net)  [  🔥  ](https://consensys.io/diligence/tools/)]
</sup><br/><br/>



# Solidity Metrics for 'CLI'

## Table of contents

- [Scope](#t-scope)
    - [Source Units in Scope](#t-source-Units-in-Scope)
        - [Deployable Logic Contracts](#t-deployable-contracts)
    - [Out of Scope](#t-out-of-scope)
        - [Excluded Source Units](#t-out-of-scope-excluded-source-units)
        - [Duplicate Source Units](#t-out-of-scope-duplicate-source-units)
        - [Doppelganger Contracts](#t-out-of-scope-doppelganger-contracts)
- [Report Overview](#t-report)
    - [Risk Summary](#t-risk)
    - [Source Lines](#t-source-lines)
    - [Inline Documentation](#t-inline-documentation)
    - [Components](#t-components)
    - [Exposed Functions](#t-exposed-functions)
    - [StateVariables](#t-statevariables)
    - [Capabilities](#t-capabilities)
    - [Dependencies](#t-package-imports)
    - [Totals](#t-totals)

## <span id=t-scope>Scope</span>

This section lists files that are in scope for the metrics report. 

- **Project:** `'CLI'`
- **Included Files:** 
    - ``
- **Excluded Paths:** 
    - ``
- **File Limit:** `undefined`
    - **Exclude File list Limit:** `undefined`

- **Workspace Repository:** `unknown` (`undefined`@`undefined`)

### <span id=t-source-Units-in-Scope>Source Units in Scope</span>

Source Units Analyzed: **`4`**<br>
Source Units in Scope: **`4`** (**100%**)

| Type | File   | Logic Contracts | Interfaces | Lines | nLines | nSLOC | Comment Lines | Complex. Score | Capabilities |
| ---- | ------ | --------------- | ---------- | ----- | ------ | ----- | ------------- | -------------- | ------------ | 
| 📝 | src\Funding.sol | 1 | **** | 238 | 234 | 121 | 87 | 86 | **<abbr title='Payable Functions'>💰</abbr>** |
| 📝 | src\MyGovernor.sol | 1 | **** | 119 | 87 | 65 | 9 | 40 | **** |
| 📝 | src\TimeLock.sol | 1 | **** | 16 | 16 | 7 | 7 | 4 | **** |
| 📝 | src\VotingToken.sol | 1 | **** | 42 | 42 | 20 | 16 | 21 | **** |
| 📝 | **Totals** | **4** | **** | **415**  | **379** | **213** | **119** | **151** | **<abbr title='Payable Functions'>💰</abbr>** |

<sub>
Legend: <a onclick="toggleVisibility('table-legend', this)">[➕]</a>
<div id="table-legend" style="display:none">

<ul>
<li> <b>Lines</b>: total lines of the source unit </li>
<li> <b>nLines</b>: normalized lines of the source unit (e.g. normalizes functions spanning multiple lines) </li>
<li> <b>nSLOC</b>: normalized source lines of code (only source-code lines; no comments, no blank lines) </li>
<li> <b>Comment Lines</b>: lines containing single or block comments </li>
<li> <b>Complexity Score</b>: a custom complexity score derived from code statements that are known to introduce code complexity (branches, loops, calls, external interfaces, ...) </li>
</ul>

</div>
</sub>


##### <span id=t-deployable-contracts>Deployable Logic Contracts</span>
Total: 4
* 📝 `Funding`
* 📝 `MyGovernor`
* 📝 `TimeLock`
* 📝 `VotingToken`



#### <span id=t-out-of-scope>Out of Scope</span>

##### <span id=t-out-of-scope-excluded-source-units>Excluded Source Units</span>

Source Units Excluded: **`0`**

<a onclick="toggleVisibility('excluded-files', this)">[➕]</a>
<div id="excluded-files" style="display:none">
| File   |
| ------ |
| None |

</div>


##### <span id=t-out-of-scope-duplicate-source-units>Duplicate Source Units</span>

Duplicate Source Units Excluded: **`0`** 

<a onclick="toggleVisibility('duplicate-files', this)">[➕]</a>
<div id="duplicate-files" style="display:none">
| File   |
| ------ |
| None |

</div>

##### <span id=t-out-of-scope-doppelganger-contracts>Doppelganger Contracts</span>

Doppelganger Contracts: **`0`** 

<a onclick="toggleVisibility('doppelganger-contracts', this)">[➕]</a>
<div id="doppelganger-contracts" style="display:none">
| File   | Contract | Doppelganger | 
| ------ | -------- | ------------ |


</div>


## <span id=t-report>Report</span>

### Overview

The analysis finished with **`0`** errors and **`0`** duplicate files.





#### <span id=t-risk>Risk</span>

<div class="wrapper" style="max-width: 512px; margin: auto">
			<canvas id="chart-risk-summary"></canvas>
</div>

#### <span id=t-source-lines>Source Lines (sloc vs. nsloc)</span>

<div class="wrapper" style="max-width: 512px; margin: auto">
    <canvas id="chart-nsloc-total"></canvas>
</div>

#### <span id=t-inline-documentation>Inline Documentation</span>

- **Comment-to-Source Ratio:** On average there are`2.09` code lines per comment (lower=better).
- **ToDo's:** `0` 

#### <span id=t-components>Components</span>

| 📝Contracts   | 📚Libraries | 🔍Interfaces | 🎨Abstract |
| ------------- | ----------- | ------------ | ---------- |
| 4 | 0  | 0  | 0 |

#### <span id=t-exposed-functions>Exposed Functions</span>

This section lists functions that are explicitly declared public or payable. Please note that getter methods for public stateVars are not included.  

| 🌐Public   | 💰Payable |
| ---------- | --------- |
| 19 | 3  | 

| External   | Internal | Private | Pure | View |
| ---------- | -------- | ------- | ---- | ---- |
| 10 | 19  | 0 | 0 | 15 |

#### <span id=t-statevariables>StateVariables</span>

| Total      | 🌐Public  |
| ---------- | --------- |
| 12  | 3 |

#### <span id=t-capabilities>Capabilities</span>

| Solidity Versions observed | 🧪 Experimental Features | 💰 Can Receive Funds | 🖥 Uses Assembly | 💣 Has Destroyable Contracts | 
| -------------------------- | ------------------------ | -------------------- | ---------------- | ---------------------------- |
| `0.8.20` |  | `yes` | **** | **** | 

| 📤 Transfers ETH | ⚡ Low-Level Calls | 👥 DelegateCall | 🧮 Uses Hash Functions | 🔖 ECRecover | 🌀 New/Create/Create2 |
| ---------------- | ----------------- | --------------- | ---------------------- | ------------ | --------------------- |
| **** | **** | **** | **** | **** | **** | 

| ♻️ TryCatch | Σ Unchecked |
| ---------- | ----------- |
| **** | **** |

#### <span id=t-package-imports>Dependencies / External Imports</span>

| Dependency / Import Path | Count  | 
| ------------------------ | ------ |
| @chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol | 1 |
| @chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol | 1 |
| @openzeppelin/contracts/access/Ownable.sol | 2 |
| @openzeppelin/contracts/governance/Governor.sol | 1 |
| @openzeppelin/contracts/governance/TimelockController.sol | 1 |
| @openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol | 1 |
| @openzeppelin/contracts/governance/extensions/GovernorSettings.sol | 1 |
| @openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol | 1 |
| @openzeppelin/contracts/governance/extensions/GovernorVotes.sol | 1 |
| @openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol | 1 |
| @openzeppelin/contracts/token/ERC20/ERC20.sol | 1 |
| @openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol | 1 |
| @openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol | 1 |
| @openzeppelin/contracts/utils/Nonces.sol | 1 |
| forge-std/console2.sol | 1 |

#### <span id=t-totals>Totals</span>

##### Summary

<div class="wrapper" style="max-width: 90%; margin: auto">
    <canvas id="chart-num-bar"></canvas>
</div>

##### AST Node Statistics

###### Function Calls

<div class="wrapper" style="max-width: 90%; margin: auto">
    <canvas id="chart-num-bar-ast-funccalls"></canvas>
</div>

###### Assembly Calls

<div class="wrapper" style="max-width: 90%; margin: auto">
    <canvas id="chart-num-bar-ast-asmcalls"></canvas>
</div>

###### AST Total

<div class="wrapper" style="max-width: 90%; margin: auto">
    <canvas id="chart-num-bar-ast"></canvas>
</div>

##### Inheritance Graph

<a onclick="toggleVisibility('surya-inherit', this)">[➕]</a>
<div id="surya-inherit" style="display:none">
<div class="wrapper" style="max-width: 512px; margin: auto">
    <div id="surya-inheritance" style="text-align: center;"></div> 
</div>
</div>

##### CallGraph

<a onclick="toggleVisibility('surya-call', this)">[➕]</a>
<div id="surya-call" style="display:none">
<div class="wrapper" style="max-width: 512px; margin: auto">
    <div id="surya-callgraph" style="text-align: center;"></div>
</div>
</div>

###### Contract Summary

<a onclick="toggleVisibility('surya-mdreport', this)">[➕]</a>
<div id="surya-mdreport" style="display:none">
 Sūrya's Description Report

 Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| src\Funding.sol | [object Promise] |
| src\MyGovernor.sol | [object Promise] |
| src\TimeLock.sol | [object Promise] |
| src\VotingToken.sol | [object Promise] |


 Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **Funding** | Implementation | Ownable, VRFConsumerBaseV2 |||
| └ | <Constructor> | Public ❗️ | 🛑  | Ownable VRFConsumerBaseV2 |
| └ | <Fallback> | External ❗️ |  💵 |NO❗️ |
| └ | <Receive Ether> | External ❗️ |  💵 |NO❗️ |
| └ | sendMoneyToContract | Public ❗️ |  💵 |NO❗️ |
| └ | addNewUser | External ❗️ | 🛑  | onlyOwner |
| └ | checkUpkeep | Internal 🔒 |   | |
| └ | performUpkeep | External ❗️ | 🛑  |NO❗️ |
| └ | fulfillRandomWords | Internal 🔒 | 🛑  | |
| └ | getUserByIndex | External ❗️ |   |NO❗️ |
| └ | getAmountThatUserNeeds | External ❗️ |   |NO❗️ |
| └ | getContractState | External ❗️ |   |NO❗️ |
| └ | getSubId | External ❗️ |   |NO❗️ |
| └ | getLatestTimestamp | External ❗️ |   |NO❗️ |
| └ | getRecentWinner | External ❗️ |   |NO❗️ |
||||||
| **MyGovernor** | Implementation | Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction, GovernorTimelockControl |||
| └ | <Constructor> | Public ❗️ | 🛑  | Governor GovernorSettings GovernorVotes GovernorVotesQuorumFraction GovernorTimelockControl |
| └ | votingDelay | Public ❗️ |   |NO❗️ |
| └ | votingPeriod | Public ❗️ |   |NO❗️ |
| └ | quorum | Public ❗️ |   |NO❗️ |
| └ | state | Public ❗️ |   |NO❗️ |
| └ | proposalNeedsQueuing | Public ❗️ |   |NO❗️ |
| └ | proposalThreshold | Public ❗️ |   |NO❗️ |
| └ | _queueOperations | Internal 🔒 | 🛑  | |
| └ | _executeOperations | Internal 🔒 | 🛑  | |
| └ | _cancel | Internal 🔒 | 🛑  | |
| └ | _executor | Internal 🔒 |   | |
||||||
| **TimeLock** | Implementation | TimelockController |||
| └ | <Constructor> | Public ❗️ | 🛑  | TimelockController |
||||||
| **VotingToken** | Implementation | ERC20, ERC20Permit, ERC20Votes, Ownable |||
| └ | <Constructor> | Public ❗️ | 🛑  | ERC20 ERC20Permit Ownable |
| └ | mint | Public ❗️ | 🛑  | onlyOwner |
| └ | _update | Internal 🔒 | 🛑  | |
| └ | nonces | Public ❗️ |   |NO❗️ |


 Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
 

</div>
____
<sub>
Thinking about smart contract security? We can provide training, ongoing advice, and smart contract auditing. [Contact us](https://consensys.io/diligence/contact/).
</sub>


