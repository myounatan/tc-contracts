import hre, { ethers } from 'hardhat';

import 'dotenv/config';
import { verify } from '../utils';

async function verifyLiveContract(contract: any, artifact: string, constructorArgs: any[]) {
  if (hre.network.name !== 'localhost' && hre.network.name !== 'hardhat') {
    await verify(hre, contract, artifact, constructorArgs);
  }
}

async function main() {
  const backendAdmin = process.env.DEV_ADDRESS;

  // deploy admin beacon

  let constructorArgs = [backendAdmin];
  const adminBeacon = await ethers.deployContract('AdminBeacon', constructorArgs);

  await adminBeacon.deployed();

  console.log('AdminBeacon deployed to:', adminBeacon.address);

  await verifyLiveContract(adminBeacon, 'contracts/admin/AdminBeacon.sol:AdminBeacon', constructorArgs);

  // deploy campaign factory

  constructorArgs = [adminBeacon.address];
  const campaignFactory = await ethers.deployContract('CampaignFactory', constructorArgs);

  await campaignFactory.deployed();

  console.log('\nCampaignFactory deployed to:', campaignFactory.address);

  await verifyLiveContract(campaignFactory, 'contracts/CampaignFactory.sol:CampaignFactory', constructorArgs);

  // deploy deployers (kek)

  const deployerNames = ['TwitterCampaignDeployer'];
  let deployers = [];

  constructorArgs = [campaignFactory.address];

  console.log('\nDeploying deployers...');

  for (const deployer of deployerNames) {
    const deployerContract = await ethers.deployContract(deployer, constructorArgs);

    await deployerContract.deployed();

    deployers.push(deployerContract);

    console.log(`${deployer} deployed to:`, deployerContract.address);

    await verifyLiveContract(deployerContract, `contracts/deployers/${deployer}.sol:${deployer}`, constructorArgs);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
