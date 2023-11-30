import { keccak256, toUtf8Bytes } from 'ethers';
import { task, types } from 'hardhat/config';

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task('keccak256', 'Prints hash output of ethereums keccak256 function')
  .addPositionalParam('topic', 'String to be hashed', 'ExampleEvent(uint256,address)', types.string)
  .setAction(async (args, hre) => {
    console.log(`\n${args.topic}`);
    console.log(`${keccak256(toUtf8Bytes(args.topic))}\n`);
  });
