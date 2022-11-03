const { ethers, getNamedAccounts } = require("hardhat");

async function cancleListing() {
  const { account2, deployer } = await getNamedAccounts();
  const tokenContract = await ethers.getContract("Token", deployer);

  const mint = await tokenContract.mint(account2, 2250);
  mint.wait(1);

  const balanceOf = await tokenContract.balanceOf(account2);
  console.log(balanceOf.toString());
}

cancleListing()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
