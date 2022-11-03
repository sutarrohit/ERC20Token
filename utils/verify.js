const { run } = require("hardhat");

const verify = async (contractAddress, args) => {
  try {
    await run("verify:verify", {
      address: contractAddress,
      args: args,
    });
  } catch (e) {
    if (e.message.toLowerCase().includes("already verified")) {
      console.log("Contract Already Verified");
    } else {
      console.error(e);
    }
  }
};

module.exports = { verify };
