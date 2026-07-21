import { ethers } from "hardhat";
import * as fs from "fs";
import * as path from "path";

async function main() {
  console.log("Starting Decoy deployment to Celo Network...");

  const [deployer] = await ethers.getSigners();
  console.log("Deploying Decoy contract with the account:", deployer?.address);

  // Deploy TitanActivityDecoy
  const TitanActivityDecoy = await ethers.getContractFactory("TitanActivityDecoy");
  const decoy = await TitanActivityDecoy.deploy(deployer.address);
  await decoy.waitForDeployment();

  const contractAddress = await decoy.getAddress();
  console.log("✅ TitanActivityDecoy successfully deployed to:", contractAddress);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
