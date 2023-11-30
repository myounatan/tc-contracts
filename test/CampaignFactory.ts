import { time, loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { expect } from "chai";
import { ethers } from "hardhat";
import { CONVERT_WEI } from '../utils';
import { ContractReceipt, ContractTransaction } from 'ethers';

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

describe("CampaignFactory", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployFactoryAndDeployers() {
    const [owner, admin, account1, account2] = await ethers.getSigners();
    const backendAdmin = await admin.getAddress();
    const account1Address = await account1.getAddress();
    const account2Address = await account2.getAddress();

    let constructorArgs = [backendAdmin];
    const adminBeacon = await ethers.deployContract('AdminBeacon', constructorArgs);
    await adminBeacon.deployed();
  
    constructorArgs = [adminBeacon.address];
    const campaignFactory = await ethers.deployContract('CampaignFactory', constructorArgs);
    await campaignFactory.deployed();

    constructorArgs = [campaignFactory.address];
    const twitterCampaignDeployer = await ethers.deployContract('TwitterCampaignDeployer', constructorArgs);
    await twitterCampaignDeployer.deployed();

    return { adminBeacon, campaignFactory, twitterCampaignDeployer, owner, admin, account1, account2, account1Address, account2Address };
  }

  it("should deploy campaign manager and execute functions properly", async function () {
    const { adminBeacon, campaignFactory, twitterCampaignDeployer, owner, admin, account1, account1Address } = await loadFixture(deployFactoryAndDeployers);

    // deploy a twitter campaign contract
    let tx: ContractTransaction = await campaignFactory.connect(account1).deployTwitterCampaign(account1Address, twitterCampaignDeployer.address);
    let receipt: ContractReceipt = await tx.wait();

    let campaignCreatedEvent = receipt.events?.find((event) => event.event == 'CampaignCreated');
    let campaignCreatedArgs = campaignCreatedEvent?.args as any;

    expect(campaignCreatedArgs).to.not.be.undefined;

    console.log(campaignCreatedArgs.contractAddress)

    const campaign = await ethers.getContractAt('TwitterCampaign', campaignCreatedArgs.contractAddress);

    // get now in unix time
    const now = await time.latest();

    // get end time in 10 hours from now
    const endTime = now + (10 * 60 * 60);

    // string name;
    // string description;
    // uint256 startTime;
    // uint256 endTime;
    // // optional
    // bool isPrivate;
    tx = await campaign.connect(account1).setupNative(
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
        value: CONVERT_WEI(2)
      }
    );
    receipt = await tx.wait();

    campaignCreatedEvent = receipt.events?.find((event) => event.event == 'TwitterCampaignCreated');
    campaignCreatedArgs = campaignCreatedEvent?.args as any;

    console.log(campaignCreatedArgs)
  });
});
