// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../CampaignLib.sol";

import "../admin/IAdminBeacon.sol";

abstract contract BaseCampaign is Ownable, Pausable, ReentrancyGuard {
    // reward info

    enum RewardType {
        NATIVE,
        ERC20
    }

    struct RewardToken {
        RewardType rewardType;
        address tokenAddress;
    }

    // campaign info

    struct RewardInfo {
        uint256 rewardsLeft;
        uint256 totalRewardsGiven;
        RewardToken rewardToken;
        string rewardString; // ex. "0.001 * a1 + 0.002 * a2" where a1 and a2 are the first two twitter reward metrics
    }

    struct CampaignInfo {
        string name;
        string description;
        uint256 startTime;
        uint256 endTime;
        // optional
        bool isPrivate;
        //uint256[] whitelistedParticipants; // array of user ids from social platforms - this could be centralized to save gas
    }

    // variables

    IAdminBeacon private adminBeacon;

    uint256 public campaignId;

    bool public isActive;

    address public creator; // also campaign owner

    bool isSetup = false;

    CampaignLib.CampaignType public campaignType;

    CampaignInfo public campaignInfo;
    RewardInfo public rewardInfo;

    mapping(address => uint256) public rewardsGiven; // participant -> tokensRewarded

    // errors

    error SetupOnce();
    error OnlyCreator();
    error ZeroAmount();
    error OnlyAdmin();
    error CampaignDoesNotExist();
    error OnlyCampaignOwner();
    error NoRewardToClaim();
    error NotEnoughRewardsLeft();
    error FailedToSendRewards(address participant, uint256 amount);
    error FailedToWithdrawFunds();

    // modifiers

    modifier setupOnce() {
        if (isSetup) revert SetupOnce();
        isSetup = true;
        _;
    }

    function _onlyCreator() internal view virtual {
        if (msg.sender != creator) revert OnlyCreator();
    }

    modifier onlyCreator() {
        _onlyCreator();
        _;
    }

    function _onlyAdmin() internal view virtual {
        if (msg.sender != adminBeacon.getAdmin()) revert OnlyAdmin();
    }

    modifier onlyAdmin() {
        _onlyAdmin();
        _;
    }

    function _nonZeroAmount(uint256 amount) internal pure virtual {
        if (amount == 0) revert ZeroAmount();
    }

    modifier nonZeroAmount(uint256 amount) {
        _nonZeroAmount(amount);
        _;
    }

    // constructor

    constructor(
        uint256 _campaignId,
        address _creator,
        IAdminBeacon _adminBeacon
    ) {
        campaignId = _campaignId;
        creator = _creator;
        adminBeacon = _adminBeacon;
    }

    // internal functions

    function _setupBase(
        CampaignInfo memory _campaignInfo,
        string memory _rewardString
    ) internal {
        isActive = true;

        campaignInfo = _campaignInfo;

        rewardInfo.rewardString = _rewardString;
    }

    function _rewardNative(
        address participant,
        uint256 _tokensRewarded
    ) internal {
        // check if there are enough tokens left to reward
        if (_tokensRewarded > rewardInfo.rewardsLeft)
            revert NotEnoughRewardsLeft();

        // update campaign state
        rewardInfo.rewardsLeft -= _tokensRewarded;
        rewardInfo.totalRewardsGiven += _tokensRewarded;

        // update user state
        rewardsGiven[participant] += _tokensRewarded;

        // send tokens to user
        (bool success, ) = payable(participant).call{value: _tokensRewarded}(
            ""
        );
        if (!success) revert FailedToSendRewards(participant, _tokensRewarded);
    }

    // function _rewardERC20

    // public functions

    function getCampaignInfo() public view returns (CampaignInfo memory) {
        return campaignInfo;
    }

    function getRewardInfo() public view returns (RewardInfo memory) {
        return rewardInfo;
    }

    function getCampaignAndRewardInfo()
        public
        view
        returns (CampaignInfo memory, RewardInfo memory)
    {
        return (campaignInfo, rewardInfo);
    }

    // public onlyCreator

    function depositNative()
        public
        payable
        onlyCreator
        nonZeroAmount(msg.value)
    {
        rewardInfo.rewardsLeft += msg.value;
    }

    function withdrawNative() public onlyCreator {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!success) revert FailedToWithdrawFunds();
    }

    // function depositERC20

    // function withdrawERC20
}
