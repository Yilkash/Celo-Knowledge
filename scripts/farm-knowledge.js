const { ethers } = require("hardhat");
const fs = require("fs");
const path = require("path");

// This script expects an army-wallets.json file in the root directory
// formatted as: [ { "address": "...", "privateKey": "..." }, ... ]

async function main() {
  console.log("🚀 Starting the Celo-Knowledge Farming Operation...");

  // Load deployed contract
  const deployInfoPath = path.join(__dirname, "../deployment-info.json");
  if (!fs.existsSync(deployInfoPath)) {
    console.error("❌ deployment-info.json not found! Please run deploy.ts first.");
    process.exit(1);
  }
  const deployInfo = JSON.parse(fs.readFileSync(deployInfoPath, "utf-8"));
  const contractAddress = deployInfo.address;
  console.log(`Targeting Contract: ${contractAddress}`);

  // Load the Army
  // We will assume the army wallets are provided via an external file 
  // typical to your previous Celo-predict setup.
  const armyPath = path.join(__dirname, "../../celo/Celo-predict/army-wallets.json");
  if (!fs.existsSync(armyPath)) {
      console.warn("⚠️ army-wallets.json not found at expected path. Please copy it into the project.");
      return;
  }
  const army = JSON.parse(fs.readFileSync(armyPath, "utf-8"));
  console.log(`⚔️  Army Loaded: ${army.length} Soldiers Ready.`);

  const provider = ethers.provider;
  const KnowledgeRegistry = await ethers.getContractFactory("KnowledgeRegistry");

  // Farm Loop
  let totalFarmed = 0;
  for (let i = 0; i < army.length; i++) {
    const soldier = army[i];
    
    try {
      const wallet = new ethers.Wallet(soldier.privateKey, provider);
      const connectedContract = KnowledgeRegistry.attach(contractAddress).connect(wallet);

      // Generate random farming data
      const fakeTitles = ["Web3 Basics", "Solidity 101", "Celo Ecosystem Guide", "Defi Trading", "NFT Launch Strategies"];
      const randomTitle = fakeTitles[Math.floor(Math.random() * fakeTitles.length)];
      
      console.log(`[Soldier #${i}] ${soldier.address} is registering resource: ${randomTitle}...`);

      const tx = await connectedContract.registerResource(
        randomTitle,
        "An automated resource uploaded during the Talent Protocol surge.",
        "https://celo.org/learn",
        "Education"
      );

      console.log(`  -> TX Broadcasted: ${tx.hash}`);
      await tx.wait();
      console.log(`  -> ✅ TX Mined!`);
      totalFarmed++;

      // Small delay to prevent RPC rate-limiting
      await new Promise(r => setTimeout(r, 2000));
      
    } catch (err) {
      console.error(`❌ Soldier #${i} Failed:`, err.message);
    }
  }

  console.log(`\n🎉 Farming Complete! Successfully pumped ${totalFarmed} transactions on-chain.`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
