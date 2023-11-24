import hre, { ethers } from 'hardhat';

import 'dotenv/config';
import { verify } from '../utils';
import { verifyLiveContract } from './utils';

const CAMPAIGG_FACTORY_ADDRESS = '0x76e982901BA14055e5601cd3Fd35DC8089518f67';

async function main() {
  const accounts = await ethers.getSigners();
  const deployer = accounts[0];
  const deployerAddress = await deployer.getAddress();

  const backendAdmin: any = process.env.BACKEND_ADMIN_ADDRESS;

  let nonce = await ethers.provider.getTransactionCount(deployerAddress);

  // deploy deployers (kek)

  const deployerNames = ['TwitterCampaignDeployer'];
  let deployers = [];

  let constructorArgs = [CAMPAIGG_FACTORY_ADDRESS];

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
