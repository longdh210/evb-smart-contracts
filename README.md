# Simple NFT Game project

Blockchain e-voting system, smart contract repo

# Settings

Create a json file with your key like this format (same level with contracts folder):

{
"account": {
"publicKey": "",
"privateKey": ""
},
"etherscan_apikey": ""
}

# Running

Try running some of the following tasks to deploy smart contract:
npm i

```localhost environment
npx hardhat node
npx hardhat run scripts/deployDeployBallot.js --network localhost
```

```polygon
npx hardhat run scripts/deployDeployBallot.js --network polygonMumbai
```
