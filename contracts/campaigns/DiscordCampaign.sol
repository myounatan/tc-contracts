// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "./BaseCampaign.sol";

import "../CampaignLib.sol";

contract DiscordCampaign is BaseCampaign {
    constructor(
        // general info
        uint256 _campaignId,
        address _creator,
        IAdminBeacon _adminBeacon
    ) BaseCampaign(_campaignId, _creator, _adminBeacon) {
        campaignType = CampaignLib.CampaignType.DISCORD;
    }
}
