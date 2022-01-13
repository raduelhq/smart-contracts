async function main() {
  // We get the contract to deploy
  const Ruel = await hre.ethers.getContractFactory("Ruel");
  const ruelContract = await Ruel.deploy();

  await ruelContract.deployed();

  console.log("Ruel token deployed to:", ruelContract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
