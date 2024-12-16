# ZombieInTruffle
Practice Project with CryptoZombie contract in Truffle. Private and personal use only.

## pre-requisite:
1. Truffle v5.11.5 (core: 5.11.5)
2. Ganache v7.9.1
3. Solidity - 0.8.21 (solc-js)
4. Node v22.11.0
5. Web3.js v1.10.0


## References
### Tech Stack 
1. Polygon Faucet: https://faucet.polygon.technology/
2. Solidity: https://soliditylang.org/
3. Openzeppelin: https://www.openzeppelin.com/
4. Openzeppelin Contract Generator: https://wizard.openzeppelin.com/
5. Truffle and Ganache: https://archive.trufflesuite.com/
6. Remix IDE: https://remix.ethereum.org/
7. Hardhat: https://hardhat.org/
8. Foundry: https://book.getfoundry.sh/
9. Truffle vs Remix vs Hardhat vs Foundry: https://ethereum-blockchain-developer.com/124-remix-vs-truffle-vs-hardhat-vs-foundry/00-overview/

### Document References
1. Solidity: https://docs.soliditylang.org/en/v0.8.28/
2. Openzepplin: https://docs.openzeppelin.com/
3. Truffle Doc: https://archive.trufflesuite.com/docs/truffle/
4. Solidity Tutorial: https://www.tutorialspoint.com/solidity/index.htm


## Setup development environment
### To setup project, execute following commands
```Shell
npm i @openzeppelin/contracts 
truffle init
```

### To compile your contracts
1. Put your contract *.sol into folder contracts
2. run command:
```Shell
truffle compile
```

### To deploy your contracts onto blockchain
1. Start Ganache
2. modify truffle-config.js to include to network setting you want to deploy your contracts. By default, it is deploy your contract to "development" network.
3. Create/Modify file migrations/1_deploy_contracts.js to specifiy the contracts artifacts (after compile) you want to deploy to 
4. run command: truffle migrate

### Run your deployed contracts
To run your deployed contracts, you can start Truffle console with:
```Shell
truffle console
```

In Truffle console, use Nodejs code to interact functions in contracts, e.g.:
```javascript
// Get the wallet address created in current network (Ganache)
let accounts = await web3.eth.getAccounts()

// Get the latest deployed ZombieNFT contract instant and mint a nft to the second wallet
let nft = await ZombieNFT.deployed()  
nft.mintTo(accounts[1])  

// Set nft contract address in to CryptoZombie contract and create a zombie for the 3rd account 
let game = await CryptoZombie.deployed()  
await game.setNFTContract(nft.address)
await game.createRandomZombie("MyZombie", {from: accounts[2]})

// level up a zombie
await game.levelUp(0, { from: accounts[0], value: web3.utils.toWei('0.001', 'ether') })

// To add time
await web3.currentProvider.send({method: "evm_increaseTime", params: [86400], id: new Date().getTime()}, () => {})
await web3.currentProvider.send({method: "evm_mine", params: []}, () => {})

// To check the current block time
await web3.eth.getBlock(await web3.eth.getBlockNumber())
```

