import { ethers } from "hardhat";
import * as fs from "fs";
import * as path from "path";

async function main() {
  console.log("Starting deployment to Celo Network...");

  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer?.address);

  // Deploy KnowledgeRegistry
  const KnowledgeRegistry = await ethers.getContractFactory("KnowledgeRegistry");
  const registry = await KnowledgeRegistry.deploy();
  await registry.waitForDeployment();

  const contractAddress = await registry.getAddress();
  console.log("✅ KnowledgeRegistry successfully deployed to:", contractAddress);

  // Save the address to a file for the farming script to use
  const deployInfo = {
    address: contractAddress,
    network: process.env.HARDHAT_NETWORK || "unknown",
    timestamp: new Date().toISOString()
  };

  const deployPath = path.join(__dirname, "../deployment-info.json");
  fs.writeFileSync(deployPath, JSON.stringify(deployInfo, null, 2));
  console.log(`Deployment info saved to ${deployPath}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
