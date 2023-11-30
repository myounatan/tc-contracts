import hre, { ethers } from 'hardhat';

import 'dotenv/config';
import { verify } from '../utils';

export async function verifyLiveContract(contract: any, artifact: string, constructorArgs: any[]) {
  if (hre.network.name !== 'localhost' && hre.network.name !== 'hardhat') {
    await verify(hre, contract, artifact, constructorArgs);
  }
}