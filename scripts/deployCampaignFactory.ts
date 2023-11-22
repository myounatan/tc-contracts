import hre, { ethers } from 'hardhat';

import 'dotenv/config';
import { verify } from '../utils';
import { verifyLiveContract } from './utils';

async function main() {
  const accounts = await ethers.getSigners();
  const deployer = accounts[0];
  const deployerAddress = await deployer.getAddress();

  const backendAdmin: any = process.env.BACKEND_ADMIN_ADDRESS;

  let nonce = await ethers.provider.getTransactionCount(deployerAddress);

  // deploy admin beacon

  let constructorArgs: any = [backendAdmin];
  const adminBeaconFactory = await ethers.getContractFactory('AdminBeacon');
  const adminBeacon = await adminBeaconFactory.deploy(constructorArgs[0], {nonce: nonce++});

  // const adminBeacon = await ethers.deployContract('AdminBeacon', constructorArgs);

  await adminBeacon.waitForDeployment();

  console.log('AdminBeacon deployed to:', await adminBeacon.getAddress());

  await verifyLiveContract(adminBeacon, 'contracts/admin/AdminBeacon.sol:AdminBeacon', constructorArgs);

  // deploy campaign factory

  constructorArgs = [await adminBeacon.getAddress()];
  const campaignFactoryFactory = await ethers.getContractFactory('CampaignFactory');
  const campaignFactory = await campaignFactoryFactory.deploy(constructorArgs[0], {nonce: nonce++});
  // const campaignFactory = await ethers.deployContract('CampaignFactory', constructorArgs);

  await campaignFactory.waitForDeployment();

  console.log('\nCampaignFactory deployed to:', await campaignFactory.getAddress());

  await verifyLiveContract(campaignFactory, 'contracts/CampaignFactory.sol:CampaignFactory', constructorArgs);

  // deploy deployers (kek)

  const deployerNames = ['TwitterCampaignDeployer'];
  let deployers = [];

  constructorArgs = [await campaignFactory.getAddress()];

  console.log('\nDeploying deployers...');

  for (const deployer of deployerNames) {
    // const deployerContract = await ethers.deployContract(deployer, constructorArgs);
    const deployerContractFactory = await ethers.getContractFactory(deployer);
    const deployerContract = await deployerContractFactory.deploy(constructorArgs[0], {nonce: nonce++});

    await deployerContract.waitForDeployment();

    deployers.push(deployerContract);

    console.log(`${deployer} deployed to:`, await deployerContract.getAddress());

    await verifyLiveContract(deployerContract, `contracts/deployers/${deployer}.sol:${deployer}`, constructorArgs);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
