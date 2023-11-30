import hre, { ethers } from 'hardhat';

import 'dotenv/config';
import { verify } from '../utils';

const CAMPAIGN_FACTORY_ADDRESS = '0x8a73b66815C3483de5796cD7721DCbbAcF71dF12';

const TWITTER_CAMPAIGN_DEPLOYER_ADDRESS = '0x5342F197C627616DfbEd86777f011d75B0AB53Bf';

async function main() {
  const backendAdmin = process.env.DEV_ADDRESS;

  let nonce = await ethers.provider.getTransactionCount(backendAdmin);

  // get campaign contract
  const campaignFactory = await ethers.getContractAt('CampaignFactory', CAMPAIGN_FACTORY_ADDRESS);

  const txn: any = await campaignFactory.deployTwitterCampaign(TWITTER_CAMPAIGN_DEPLOYER_ADDRESS, {nonce: nonce++});

  console.log(txn.hash)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
