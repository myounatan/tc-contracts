// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./CampaignLib.sol";

import "./deployers/IBaseDeployer.sol";

import "./admin/IAdminBeacon.sol";

import "./campaigns/TwitterCampaign.sol";
import "./campaigns/DiscordCampaign.sol";

// import "hardhat/console.sol";

contract CampaignFactory is Ownable {
    // campaign info

    struct CampaignContract {
        address contractAddress;
        uint256 campaignId;
        CampaignLib.CampaignType campaignType;
    }

    // variables

    IAdminBeacon private adminBeacon;

    CampaignContract[] public campaigns;
    uint256 public numCampaigns = 0;

    // events

    event CampaignCreated(
        address indexed contractAddress,
        uint256 indexed campaignId,
        CampaignLib.CampaignType indexed campaignType
    );

    // errors

    error OnlyAdmin();
    error InvalidCampaignType();

    // modifiers

    modifier onlyAdmin() {
        if (msg.sender != adminBeacon.getAdmin()) revert OnlyAdmin();
        _;
    }

    // constructor

    constructor(IAdminBeacon _adminBeacon) {
        adminBeacon = _adminBeacon;
    }

    // internal functions

    function _recordNewCampaign(
        address _contractAddress,
        uint256 _campaignId,
        CampaignLib.CampaignType _campaignType
    ) internal returns (CampaignContract memory) {
        CampaignContract memory newCampaign = CampaignContract({
            contractAddress: _contractAddress,
            campaignId: _campaignId,
            campaignType: _campaignType
        });

        campaigns[_campaignId] = newCampaign;

        emit CampaignCreated(_contractAddress, _campaignId, _campaignType);

        return newCampaign;
    }

    // admin only functions

    function deployTwitterCampaign(
        address _creator,
        IBaseDeployer _deployer
    ) external onlyAdmin returns (CampaignContract memory campaign) {
        uint256 campaignId = campaigns.length + 1;

        address contractAddress = _deployer.deployCampaign(
            campaignId,
            _creator,
            adminBeacon
        );

        campaign = _recordNewCampaign(
            contractAddress,
            campaignId,
            CampaignLib.CampaignType.TWITTER
        );
    }

    function deployDiscordCampaign(
        address _creator,
        IBaseDeployer _deployer
    ) external onlyAdmin returns (CampaignContract memory campaign) {
        uint256 campaignId = campaigns.length + 1;

        address contractAddress = _deployer.deployCampaign(
            campaignId,
            _creator,
            adminBeacon
        );

        campaign = _recordNewCampaign(
            contractAddress,
            campaignId,
            CampaignLib.CampaignType.DISCORD
        );
    }
}
