// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./CampaignLib.sol";

import "./deployers/IBaseDeployer.sol";

import "./admin/IAdminBeacon.sol";

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
        address indexed deployerAddress,
        address indexed campaignAddress,
        address indexed creator,
        CampaignLib.CampaignType campaignType,
        uint256 campaignId
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
        IBaseDeployer _deployer,
        address _contractAddress,
        address _creator,
        CampaignLib.CampaignType _campaignType
    ) internal returns (CampaignContract memory) {
        uint256 campaignId = numCampaigns++;

        CampaignContract memory newCampaign = CampaignContract({
            contractAddress: _contractAddress,
            campaignId: campaignId,
            campaignType: _campaignType
        });

        campaigns.push(newCampaign);

        emit CampaignCreated(
            address(_deployer),
            _contractAddress,
            _creator,
            _campaignType,
            campaignId
        );

        return newCampaign;
    }

    // admin only functions

    function deployTwitterCampaign(
        IBaseDeployer _deployer
    ) external nonReentrant {
        address creator = msg.sender;
        uint256 campaignId = numCampaigns;

        address contractAddress = _deployer.deployCampaign(
            campaignId,
            creator,
            adminBeacon
        );

        _recordNewCampaign(
            _deployer,
            contractAddress,
            creator,
            CampaignLib.CampaignType.TWITTER
        );
    }

    function deployDiscordCampaign(
        IBaseDeployer _deployer
    ) external nonReentrant {
        address creator = msg.sender;
        uint256 campaignId = numCampaigns;

        address contractAddress = _deployer.deployCampaign(
            campaignId,
            creator,
            adminBeacon
        );

        _recordNewCampaign(
            _deployer,
            contractAddress,
            creator,
            CampaignLib.CampaignType.DISCORD
        );
    }
}
