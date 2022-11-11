var { votingContractAddress } = require("../config");
var VotingContract = require("../artifacts/contracts/Voting.sol/Ballot.json");
var Web3 = require("web3");
const { ethers } = require("hardhat");
const fs = require("fs");

var web3 = new Web3(
    "https://eth-goerli.g.alchemy.com/v2/BAexJjh839qZdzF1_CxPlqcd3WRQexU9"
);
let provider = new ethers.providers.JsonRpcProvider(
    "https://eth-goerli.g.alchemy.com/v2/BAexJjh839qZdzF1_CxPlqcd3WRQexU9"
);

const main = async () => {
    let accounts = { infor: [] };
    for (let i = 0; i < 150; i++) {
        let accountObject = await web3.eth.accounts.create();
        accounts.infor.push({
            address: accountObject.address,
            privateKey: accountObject.privateKey,
        });
    }
    var json = JSON.stringify(accounts);
    await fs.writeFileSync("./infor.json", `${json}`);
};

main();
