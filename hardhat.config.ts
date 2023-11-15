import 'dotenv/config'

import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import '@nomiclabs/hardhat-ethers';

const config: HardhatUserConfig = {
  solidity: "0.8.18",
  networks: {
    localhost: {
      url: 'http://127.0.0.1:8545/',
      chainId: 31337,
    },
    goerli: {
      url: process.env.ALCHEMY_BASEGOERLI,
      accounts: [process.env.DEV_PRIVATE_KEY || ''],
      chainId: 84531,
    },
    sepolia: { // same as basesepolia
      url: process.env.QUICKNODE_BASESEPOLIA,
      accounts: [process.env.DEV_PRIVATE_KEY || ''],
      chainId: 84532,
    },
  },
  etherscan: {
    apiKey: {
      'mumbai': `${process.env.MUMBAI_SCAN_KEY}`,
      'base-goerli': "PLACEHOLDER_STRING"
    },
    customChains: [
      {
        network: 'base-goerli',
        chainId: 84531,
        urls: {
          apiURL: 'https://api-goerli.basescan.org/api',
          browserURL: 'https://goerli.basescan.org'
        }
      }
    ]
  }
};

export default config;
