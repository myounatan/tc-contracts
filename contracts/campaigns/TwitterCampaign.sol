// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "./BaseCampaign.sol";

import "../CampaignLib.sol";

contract TwitterCampaign is BaseCampaign {
    // twitter info

    enum TwitterSecurityMetric {
        FOLLOWERS,
        TWEETS,
        FOLLOWS_USER,
        IS_VERIFIED,
        ACCOUNT_AGE
    }

    struct TwitterSecurityInfo {
        TwitterSecurityMetric metric;
        uint256 data;
    }

    enum TwitterRewardMetric {
        LIKES,
        RETWEETS,
        REPLIES,
        QUOTE_TWEETS,
        IMPRESSIONS
    }

    struct TweetRewardInfo {
        TwitterRewardMetric metric;
        uint256 tokensPerMetric;
    }

    struct TweetInfo {
        uint256 likes;
        uint256 retweets;
        uint256 replies;
        uint256 quoteTweets;
        uint256 impressions;
    }

    // variables

    uint256 public ownerUserId;

    string public tweetString;

    // TweetRewardInfo[] public tweetRewardInfo;
    mapping(TwitterRewardMetric => uint256) public tokensPerMetric;

    // TwitterSecurityInfo[] public twitterSecurityInfo;
    mapping(TwitterSecurityMetric => uint256) public securityInfo;

    mapping(uint256 => TweetInfo) public lastTweetInfoRewarded; // tweetId -> TweetInfo

    // events

    event TwitterCampaignCreated(
        uint256 indexed campaignId,
        CampaignLib.CampaignType indexed campaignType,
        address indexed creator,
        CampaignInfo campaignInfo,
        uint256 rewardsLeft,
        RewardToken rewardToken,
        uint256 ownerUserId,
        string tweetString,
        TweetRewardInfo[] rewardInfo,
        TwitterSecurityInfo[] securityInfo
    );

    event TwitterCampaignRewardClaimed(
        RewardType indexed rewardType,
        address tokenAddress,
        uint256 indexed campaignId,
        address indexed wallet,
        uint256 tweetId,
        uint256 tokensRewarded,
        TweetInfo rewardedTweetInfo,
        string rewardStringUsed
    );

    // constructor

    constructor(
        // general info
        uint256 _campaignId,
        address _creator,
        IAdminBeacon _adminBeacon
    ) BaseCampaign(_campaignId, _creator, _adminBeacon) {
        campaignType = CampaignLib.CampaignType.TWITTER;
    }

    function getTwitterCampaignInfo()
        external
        view
        returns (
            uint256,
            address,
            CampaignState,
            CampaignInfo memory,
            RewardInfo memory,
            uint256,
            string memory,
            TweetRewardInfo[] memory,
            TwitterSecurityInfo[] memory,
            uint256
        )
    {
        uint256 twitterSecurityInfoCount = 0;
        for (uint256 i = 0; i < 5; i++) {
            if (securityInfo[TwitterSecurityMetric(i)] > 0) {
                twitterSecurityInfoCount++;
            }
        }
        TwitterSecurityInfo[]
            memory getTwitterSecurityInfo = new TwitterSecurityInfo[](
                twitterSecurityInfoCount
            );

        uint256 twitterSecurityInfoIndex = 0;
        for (uint256 i = 0; i < 5; i++) {
            if (securityInfo[TwitterSecurityMetric(i)] > 0) {
                getTwitterSecurityInfo[
                    twitterSecurityInfoIndex
                ] = TwitterSecurityInfo(
                    TwitterSecurityMetric(i),
                    securityInfo[TwitterSecurityMetric(i)]
                );
                twitterSecurityInfoIndex++;
            }
        }

        uint256 tweetRewardInfoCount = 0;
        for (uint256 i = 0; i < 5; i++) {
            if (tokensPerMetric[TwitterRewardMetric(i)] > 0) {
                tweetRewardInfoCount++;
            }
        }
        TweetRewardInfo[] memory getTweetRewardInfo = new TweetRewardInfo[](
            tweetRewardInfoCount
        );

        uint256 tweetRewardInfoIndex = 0;
        for (uint256 i = 0; i < 5; i++) {
            if (tokensPerMetric[TwitterRewardMetric(i)] > 0) {
                getTweetRewardInfo[tweetRewardInfoIndex] = TweetRewardInfo(
                    TwitterRewardMetric(i),
                    tokensPerMetric[TwitterRewardMetric(i)]
                );
                tweetRewardInfoIndex++;
            }
        }

        return (
            campaignId,
            creator,
            getState(),
            campaignInfo,
            rewardInfo,
            ownerUserId,
            tweetString,
            getTweetRewardInfo,
            getTwitterSecurityInfo,
            _rewardsLeft()
        );
    }

    // owner setup

    function _setup(
        // general info
        CampaignInfo memory _campaignInfo,
        string memory _rewardString,
        // twitter info
        uint256 _ownerTwitterUserId,
        string memory _tweetString,
        TweetRewardInfo[] memory _tweetRewardInfo,
        TwitterSecurityInfo[] memory _twitterSecurityInfo
    ) internal {
        _setupBase(_campaignInfo, _rewardString);

        {
            ownerUserId = _ownerTwitterUserId;
            tweetString = _tweetString;

            for (uint256 i = 0; i < _tweetRewardInfo.length; i++) {
                // tweetRewardInfo.push(_tweetRewardInfo[i]);
                tokensPerMetric[_tweetRewardInfo[i].metric] = _tweetRewardInfo[
                    i
                ].tokensPerMetric;
            }

            for (uint256 i = 0; i < _twitterSecurityInfo.length; i++) {
                // twitterSecurityInfo.push(_twitterSecurityInfo[i]);
                securityInfo[
                    _twitterSecurityInfo[i].metric
                ] = _twitterSecurityInfo[i].data;
            }
        }

        emit TwitterCampaignCreated(
            campaignId,
            campaignType,
            creator,
            campaignInfo,
            _rewardsLeft(),
            rewardInfo.rewardToken,
            ownerUserId,
            tweetString,
            _tweetRewardInfo,
            _twitterSecurityInfo
        );
    }

    function setupNative(
        CampaignInfo memory _campaignInfo,
        string memory _rewardString,
        uint256 _ownerTwitterUserId,
        string memory _tweetString,
        TweetRewardInfo[] memory _tweetRewardInfo,
        TwitterSecurityInfo[] memory _twitterSecurityInfo
    ) external onlyAdmin setupOnce {
        rewardInfo.rewardToken = RewardToken({
            rewardType: RewardType.NATIVE,
            tokenAddress: address(0)
        });

        // rewardInfo.rewardsLeft = msg.value;

        _setup(
            _campaignInfo,
            _rewardString,
            _ownerTwitterUserId,
            _tweetString,
            _tweetRewardInfo,
            _twitterSecurityInfo
        );
    }

    function setupERC20(
        address _tokenAddress,
        CampaignInfo memory _campaignInfo,
        string memory _rewardString,
        uint256 _ownerTwitterUserId,
        string memory _tweetString,
        TweetRewardInfo[] memory _tweetRewardInfo,
        TwitterSecurityInfo[] memory _twitterSecurityInfo
    ) external onlyAdmin setupOnce {
        rewardInfo.rewardToken = RewardToken({
            rewardType: RewardType.ERC20,
            tokenAddress: _tokenAddress
        });

        // rewardInfo.rewardsLeft = msg.value; // must deposit separately

        _setup(
            _campaignInfo,
            _rewardString,
            _ownerTwitterUserId,
            _tweetString,
            _tweetRewardInfo,
            _twitterSecurityInfo
        );
    }

    function claimRewardNativeTo(
        address participant,
        uint256 _tweetId,
        TweetInfo memory _currentTweetInfo,
        TweetInfo memory _rewardedTweetInfo,
        uint256 _tokensRewarded,
        string memory _rewardStringUsed
    ) public nonReentrant onlyAdmin {
        _rewardNative(participant, _tokensRewarded);

        // update tweet info
        lastTweetInfoRewarded[_tweetId] = _currentTweetInfo;

        emit TwitterCampaignRewardClaimed(
            RewardType.NATIVE,
            address(0),
            campaignId,
            participant,
            _tweetId,
            _tokensRewarded,
            _rewardedTweetInfo,
            _rewardStringUsed
        );
    }

    function claimRewardERC20To(
        address participant,
        uint256 _tweetId,
        TweetInfo memory _currentTweetInfo,
        TweetInfo memory _rewardedTweetInfo,
        uint256 _tokensRewarded,
        string memory _rewardStringUsed
    ) public nonReentrant onlyAdmin {
        _rewardERC20(participant, _tokensRewarded);

        // update tweet info
        lastTweetInfoRewarded[_tweetId] = _currentTweetInfo;

        emit TwitterCampaignRewardClaimed(
            RewardType.ERC20,
            rewardInfo.rewardToken.tokenAddress,
            campaignId,
            participant,
            _tweetId,
            _tokensRewarded,
            _rewardedTweetInfo,
            _rewardStringUsed
        );
    }
}
