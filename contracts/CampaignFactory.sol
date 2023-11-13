// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./CampaignLib.sol";

import "./deployers/IBaseDeployer.sol";

import "./admin/IAdminBeacon.sol";

import "./campaigns/TwitterCampaign.sol";
import "./campaigns/DiscordCampaign.sol";

// import "hardhat/console.sol";

contract CampaignFactory is Ownable, ReentrancyGuard {
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
        CampaignLib.CampaignType _campaignType
    ) internal returns (CampaignContract memory) {
        uint256 campaignId = numCampaigns++;

        CampaignContract memory newCampaign = CampaignContract({
            contractAddress: _contractAddress,
            campaignId: campaignId,
            campaignType: _campaignType
        });

        campaigns.push(newCampaign);

        emit CampaignCreated(_contractAddress, campaignId, _campaignType);

        return newCampaign;
    }

    // admin only functions

    function deployTwitterCampaign(
        address _creator,
        IBaseDeployer _deployer
    ) external nonReentrant {
        uint256 campaignId = numCampaigns;

        address contractAddress = _deployer.deployCampaign(
            campaignId,
            _creator,
            adminBeacon
        );

        _recordNewCampaign(contractAddress, CampaignLib.CampaignType.TWITTER);
    }

    function deployDiscordCampaign(
        address _creator,
        IBaseDeployer _deployer
    ) external nonReentrant {
        uint256 campaignId = numCampaigns;

        address contractAddress = _deployer.deployCampaign(
            campaignId,
            _creator,
            adminBeacon
        );

        _recordNewCampaign(contractAddress, CampaignLib.CampaignType.DISCORD);
    }
}
