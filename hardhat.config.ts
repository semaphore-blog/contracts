import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.23",
  paths: {
    sources: "./src",
    tests: "./test/e2e",
    cache: "./cache",
    artifacts: "./artifacts",
  },
};

export default config;
