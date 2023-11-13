// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../CampaignLib.sol";

import "../admin/IAdminBeacon.sol";

abstract contract BaseCampaign is Ownable, Pausable, ReentrancyGuard {
    // state

    enum CampaignState {
        SETUP,
        ACTIVE,
        ENDED
    }

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
    error LiabilityTimeNotPassed();

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

        _transferOwnership(_creator);
    }

    // internal functions

    function _setupBase(
        CampaignInfo memory _campaignInfo,
        string memory _rewardString
    ) internal {
        campaignInfo = _campaignInfo;

        rewardInfo.rewardString = _rewardString;
    }

    function _rewardNative(
        address participant,
        uint256 _tokensRewarded
    ) internal virtual {
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

    function _withdrawNativeAmountTo(
        address _to,
        uint256 _amount
    ) internal virtual nonZeroAmount(_amount) {
        (bool success, ) = payable(_to).call{value: _amount}("");
        if (!success) revert FailedToWithdrawFunds();
    }

    function _endCampaignIfFundsZero() internal virtual {
        if (rewardInfo.rewardsLeft == 0) {
            campaignInfo.endTime = block.timestamp;
        }
    }

    // function _rewardERC20

    // override transferOwnership so they can only renounce
    // TODO: in the future, make this a backend admin only method
    //       that also accepts a twitter user id as new owner
    function transferOwnership(
        address newOwner
    ) public virtual override onlyOwner {}

    // public functions

    function getState() public view virtual returns (CampaignState) {
        if (block.timestamp < campaignInfo.startTime) {
            return CampaignState.SETUP;
        }

        if (
            block.timestamp >= campaignInfo.startTime &&
            block.timestamp < campaignInfo.endTime
        ) {
            return CampaignState.ACTIVE;
        }

        return CampaignState.SETUP;
    }

    function getCampaignInfo()
        public
        view
        virtual
        returns (CampaignInfo memory)
    {
        return campaignInfo;
    }

    function getRewardInfo() public view virtual returns (RewardInfo memory) {
        return rewardInfo;
    }

    function getFullState()
        public
        view
        virtual
        returns (CampaignState, CampaignInfo memory, RewardInfo memory)
    {
        return (getState(), campaignInfo, rewardInfo);
    }

    // public onlyAdmin

    // only allowed to call this method 30 days after the campaign has ended, for liability reasons
    function withdrawAdminNative(address _to) public onlyAdmin {
        if (block.timestamp < campaignInfo.endTime + 30 days)
            revert LiabilityTimeNotPassed();

        _withdrawNativeAmountTo(_to, address(this).balance);
    }

    // function withdrawAdminERC20

    // public onlyCreator

    function depositNative()
        public
        payable
        virtual
        onlyCreator
        nonZeroAmount(msg.value)
    {
        // TODO: if campaign is over, don't allow deposits

        rewardInfo.rewardsLeft += msg.value;
    }

    function restartCampaign(
        uint256 _newEndTime
    ) public payable virtual onlyCreator nonZeroAmount(msg.value) {
        campaignInfo.endTime = _newEndTime;
    }

    function withdrawNative(uint256 _amount) public onlyCreator {
        _withdrawNativeAmountTo(msg.sender, _amount);

        _endCampaignIfFundsZero();
    }

    function withdrawAllNative() public onlyCreator {
        _withdrawNativeAmountTo(msg.sender, address(this).balance);

        _endCampaignIfFundsZero();
    }

    // function depositERC20

    // function withdrawERC20
}
