# ZombieInTruffle
Practice Project with CryptoZombie contract in Truffle. Private and personal use only.

pre-requisite:
1. Truffle v5.11.5 (core: 5.11.5)
2. Ganache v7.9.1
3. Solidity - 0.8.21 (solc-js)
4. Node v22.11.0
5. Web3.js v1.10.0


To setup project, execute following commands
1. npm i @openzeppelin/contracts 
2. truffle init


To compile your contracts
1. Put your contract *.sol into folder contracts
2. run command: truffle compile


To deploy your contracts onto chain
1. Start Ganache
2. modify truffle-config.js to include to network setting you want to deploy your contracts. By default, it is deploy your contract to "development" network.
3. Create/Modify file migrations/1_deploy_contracts.js to specifiy the contracts artifacts (after compile) you want to deploy to 
4. run command: truffle migrate  