import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { Contract, parseEther } from 'ethers';

// cosntructorArgs is an array here
export const verify = async (hre: HardhatRuntimeEnvironment, contract: Contract, contractPath: string, constructorArgs: any) => {
  console.log('Verifying contract...');

  const deploymentTxn = await contract.deploymentTransaction();
  if (!deploymentTxn) {
    throw new Error('Contract has not been deployed');
  }
  
  // wait 6 blocks before verification to ensure etherscan is up to date
  const numBlocks = 6;
  console.log(`Waiting for ${numBlocks} blocks...`);
  // for (let i = 1; i <= numBlocks; i++) {
  //   //if (i % 2 == 0) {
  //   console.log(`Waiting for block ${i}/${numBlocks}...`);
  //   //}
  //   await hre.ethers.provider.waitForTransaction(deploymentTxn.hash, i);
  // }

  let currentBlock = await hre.ethers.provider.getBlockNumber();
  while (currentBlock + numBlocks > (await hre.ethers.provider.getBlockNumber())) {}

  await hre.run('verify:verify', { address: await contract.getAddress(), contract: contractPath, constructorArguments: constructorArgs });

  console.log('Contract verified (still check etherscan)!');
};

export const CONVERT_WEI = (amount: number): bigint => {
  return parseEther(amount.toString());
};