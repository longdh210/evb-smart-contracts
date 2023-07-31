var { votingContractRootAddress } = require('../configVotingRoot');
var VotingContract = require('../artifacts/contracts/optimism/FromL2_ControlL1Greeter.sol/FromL2_ControlL1.json');
var Web3 = require('web3');
var { ethers } = require('hardhat');
var { MerkleTree } = require('merkletreejs');
var kekcak256 = require('keccak256');
var Account = require('../infor.json');
var key = require('../key.json');
var { arrayAccounts } = require('../array_account50');

// let provider = new ethers.providers.JsonRpcProvider(
//   "https://polygon-mumbai.g.alchemy.com/v2/EAAlM0-rm4pHavxVcH0ZV9Sm0JYhxoRf"
// );

// let provider = new ethers.providers.JsonRpcProvider(
//   "https://eth-goerli.g.alchemy.com/v2/BAexJjh839qZdzF1_CxPlqcd3WRQexU9"
// );

// var web3 = new Web3(
//   new Web3.providers.HttpProvider(
//     "https://data-seed-prebsc-1-s1.binance.org:8545"
//   )
// );

// var provider = new ethers.providers.JsonRpcProvider(
//   "https://opt-goerli.g.alchemy.com/v2/OYewU55MBKeKsGplDHhzVYq2z1a-IFdO"
// );

var provider = new ethers.providers.JsonRpcProvider(
  'https://eth-sepolia.g.alchemy.com/v2/u24_snqkQZKIuaapWJBPm2abVHEbjwWe'
);

const main = async () => {
  const leaves = arrayAccounts.map((x) => kekcak256(x));
  const tree = new MerkleTree(leaves, kekcak256, { sortPairs: true });
  const root = tree.getRoot().toString('hex');
  console.log(root);

  let votingContract = new ethers.Contract(
    votingContractRootAddress,
    VotingContract.abi,
    provider
  );

  for (let i = 0; i < 50; i++) {
    const leaf = kekcak256(Account.infor[i].address);
    const proof = tree.getHexProof(leaf);
    let inputProof = JSON.stringify(proof);
    inputProof = JSON.parse(inputProof);
    let wallet = new ethers.Wallet(Account.infor[i].privateKey, provider);
    const gasPrice = await wallet.getGasPrice();
    let overrides = {
      gasPrice: gasPrice,
    };
    await votingContract.connect(wallet).vote(0, 0, inputProof, overrides);
  }
};

console.time();
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
console.timeEnd();
