import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
//import "@nomicfoundation/hardhat-verify";
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
    testnet: {
      url: process.env.PEGASUS_TESTNET_RPC_URL,
      accounts: [String(PRIVATE_KEY)],
    },
  },
};

export default config;
