const { ethers } = require("hardhat");
const { devlopmentChains } = require("../hardhat-config-helper");
const { verify } = require("../utils/verify");

module.exports = async function ({ getNamedAddress, deployments }) {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();

  log("---------------------------------------------");

  args = [];
  const contract = await deploy("Token", {
    from: deployer,
    args: args,
    log: true,
    waitConfirmations: network.config.blockconfirmations || 1,
  });

  console.log(`contract deployed : ${contract.address} || deployer : ${deployer}`);

  if (!devlopmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
    log("Verifying......");
    await verify(contract.address, args);
  }
  log("---------------------------------------------");
};
