require("@nomicfoundation/hardhat-toolbox");
// const key = require("./key.json");

module.exports = {
    networks: {
        hardhat: {
            chainId: 1337,
        },
        // rinkeby: {
        //     url: "https://eth-rinkeby.alchemyapi.io/v2/kAPtSA_EMLRedffB6D1Ehre3rQQ2pmn2",
        //     accounts: [key.PRIVATE_KEY],
        // },
    },
    etherscan: {
        apiKey: "GU9I8IGYKY43RYC758W6E5K69Y5FJIRJ98",
    },
    solidity: "0.8.4",
};
