import hre, { ethers } from 'hardhat';

import 'dotenv/config';
import { CONVERT_WEI, verify } from '../utils';

const TWITTER_CAMPAIGN_ADDRESS = '0x3fd0fC23646aD18FcCd6C7C8DA40Dec799462009';

enum TwitterRewardMetric {
  LIKES,
  RETWEETS,
  REPLIES,
  QUOTE_TWEETS,
  IMPRESSIONS
}

enum TwitterSecurityMetric {
  FOLLOWERS,
  TWEETS,
  FOLLOWS_USER,
  IS_VERIFIED,
  ACCOUNT_AGE
}

async function main() {
  const backendAdmin = process.env.DEV_ADDRESS;

  let nonce = await ethers.provider.getTransactionCount(backendAdmin);

  // get campaign contract
  const twitterCampaign: any = await ethers.getContractAt('TwitterCampaign', TWITTER_CAMPAIGN_ADDRESS);

  // get now in unix time
  const now = new Date().getTime();

  // get end time in 10 hours from now
  const endTime = now + (10 * 60 * 60);

  const txn: any = await twitterCampaign.setupNative(
    {
      name: 'Test Campaign',
      description: 'Test Campaign Description',
      startTime: now,
      endTime: endTime,
      isPrivate: false,
    },
    'r1 + r2',
    69420,
    '#TestCampaign',
    [ // tweet reward info
      {
        metric: TwitterRewardMetric.LIKES,
        tokensPerMetric: CONVERT_WEI(0.01)
      },
      {
        metric: TwitterRewardMetric.RETWEETS,
        tokensPerMetric: CONVERT_WEI(0.02)
      }
    ],
    [ // tweet security info
      {
        metric: TwitterSecurityMetric.FOLLOWERS,
        data: 1
      }
    ],
    {
      value: CONVERT_WEI(0.0001)
    }
  );

  console.log(txn.hash)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
