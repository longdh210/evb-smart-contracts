var Web3 = require("web3");
const { ethers } = require("hardhat");
const fs = require("fs");
const Accounts = require("../infor.json");

// var web3 = new Web3(
//   "https://eth-goerli.g.alchemy.com/v2/BAexJjh839qZdzF1_CxPlqcd3WRQexU9"
// );
var web3 = new Web3();
let provider = new ethers.providers.JsonRpcProvider(
  "https://eth-goerli.g.alchemy.com/v2/BAexJjh839qZdzF1_CxPlqcd3WRQexU9"
);

const main = async () => {
  // let accounts = { infor: [] };
  // for (let i = 0; i < 50; i++) {
  //   let accountObject = await web3.eth.accounts.create();
  //   accounts.infor.push({
  //     address: accountObject.address,
  //     privateKey: accountObject.privateKey,
  //   });
  // }
  // var json = JSON.stringify(accounts);
  // await fs.writeFileSync("./infor2.json", `${json}`);
  console.log(Accounts.infor[100]);
};

main();
