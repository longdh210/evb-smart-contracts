var { votingContractAddress } = require("../config");
var VotingContract = require("../artifacts/contracts/Ballot.sol/Ballot.json");
var Web3 = require("web3");
var { ethers } = require("hardhat");
var Account = require("../infor.json");
var key = require("../key.json");

// var web3 = new Web3(
//   new Web3.providers.HttpProvider(
//     "https://polygon-mumbai.g.alchemy.com/v2/EAAlM0-rm4pHavxVcH0ZV9Sm0JYhxoRf"
//   )
// );
// let provider = new ethers.providers.JsonRpcProvider(
//   "https://polygon-mumbai.g.alchemy.com/v2/EAAlM0-rm4pHavxVcH0ZV9Sm0JYhxoRf"
// );

// let provider = new ethers.providers.JsonRpcProvider(
//   "https://eth-goerli.g.alchemy.com/v2/BAexJjh839qZdzF1_CxPlqcd3WRQexU9"
// );

let provider = new ethers.providers.JsonRpcProvider(
  "https://data-seed-prebsc-1-s3.binance.org:8545"
);

const main = async () => {
  let votingContract = new ethers.Contract(
    votingContractAddress,
    VotingContract.abi,
    provider
  );
  let owner = new ethers.Wallet(key.account.privateKey, provider);

  for (let i = 0; i < 150; i++) {
    const gasPrice = await owner.getGasPrice();
    let overrides = {
      gasPrice: gasPrice,
    };
    await votingContract
      .connect(owner)
      .giveRightToVote(0, Account.infor[i].address, overrides);
  }

  for (let i = 0; i < 150; i++) {
    let wallet = new ethers.Wallet(Account.infor[i].privateKey, provider);
    const gasPrice = await wallet.getGasPrice();
    let overrides = {
      gasPrice: gasPrice,
    };
    await votingContract.connect(wallet).vote(0, 0, overrides);
  }
};

console.time();
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
console.timeEnd();
