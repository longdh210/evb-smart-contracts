require('@nomicfoundation/hardhat-toolbox')
require('@nomiclabs/hardhat-ethers')
require('@nomiclabs/hardhat-etherscan')
const { version } = require('ethers')
const key = require('./key.json')

module.exports = {
  networks: {
    hardhat: {
      chainId: 1337,
    },
    polygonMumbai: {
      chainId: 80001,
      url: 'https://polygon-mumbai.g.alchemy.com/v2/EAAlM0-rm4pHavxVcH0ZV9Sm0JYhxoRf',
      accounts: [key.account.privateKey],
    },
    goerli: {
      chainId: 5,
      url: 'https://eth-goerli.g.alchemy.com/v2/DfH8hZGjc2FWzIzbEGxrg21UPkDmqK6w',
      accounts: [key.account.privateKey],
    },
    bsc: {
      url: 'https://data-seed-prebsc-1-s1.binance.org:8545',
      chainId: 97,
      accounts: [key.account.privateKey],
    },
    optimismGoerli: {
      chainId: 420,
      url: 'https://opt-goerli.g.alchemy.com/v2/OYewU55MBKeKsGplDHhzVYq2z1a-IFdO',
      accounts: [key.account.privateKey],
    },
    zksync: {
      chainId: 280,
      url: 'https://testnet.era.zksync.dev',
      accounts: [key.account.privateKey],
    },
    sepolia: {
      chainId: 11155111,
      url: 'https://eth-sepolia.g.alchemy.com/v2/u24_snqkQZKIuaapWJBPm2abVHEbjwWe',
      accounts: [key.account.privateKey],
    },
  },
  etherscan: {
    // apiKey: "GU9I8IGYKY43RYC758W6E5K69Y5FJIRJ98",
    apiKey: {
      polygonMumbai: 'QKJEMAGZ31PSKFG5XZFTIW7KWV2M1135RK',
    },
  },
  solidity: {
    version: '0.8.13',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      viaIR: true,
    },
  },
}
