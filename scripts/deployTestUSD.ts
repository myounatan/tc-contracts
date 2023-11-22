import hre, { ethers } from 'hardhat';

import 'dotenv/config';
import { verify } from '../utils';
import { verifyLiveContract } from './utils';

/*

TestUSD deployed to: 0xAcdDCce2020C869Ba35883c53BB3B74282243DcD

*/

const ADMIN_BEACON = '0x43Fd45fa65C60Bc8552947DE21F767A0eC5985F2';

async function main() {
  // deploy TestUSD

  let constructorArgs: any = [ADMIN_BEACON];
  const testUSDFactory = await ethers.getContractFactory('TestUSD');
  const testUSD = await testUSDFactory.deploy(constructorArgs[0]);

  await testUSD.waitForDeployment();

  console.log('TestUSD deployed to:', await testUSD.getAddress());

  await verifyLiveContract(testUSD, 'contracts/testnet/TestUSD.sol:TestUSD', constructorArgs);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
