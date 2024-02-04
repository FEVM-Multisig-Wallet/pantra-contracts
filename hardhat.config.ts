import { HardhatUserConfig } from "hardhat/config";
//import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-etherscan";
import { config as envConfig } from "dotenv";

envConfig();

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20",
  },
  networks: {
    mainnet: {
      url: process.env.PHEONIX_MAINNET_RPC_URL,
      accounts: [String(PRIVATE_KEY)],
    },
    pegasus: {
      url: process.env.PEGASUS_TESTNET_RPC_URL,
      accounts: [String(PRIVATE_KEY)],
    },
  },
  etherscan: {
    apiKey: {
      goerli: String(process.env.GOERLI_ETHERSCAN_API_KEY),
      pegasus: String(process.env.PEGASUS_BLOCKSCOUT_API_KEY)
    },
    customChains: [
      {
        network: "pegasus",
        chainId: 1891,
        urls: {
          apiURL: "https://pegasus.lightlink.io/api",
          browserURL: "https://pegasus.lightlink.io"
        }
      }
    ]
  }
};

export default config;
