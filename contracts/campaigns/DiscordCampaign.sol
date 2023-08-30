// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "./BaseCampaign.sol";

import "../CampaignLib.sol";

contract DiscordCampaign is BaseCampaign {
    CampaignLib.CampaignType public override campaignType =
        CampaignLib.CampaignType.DISCORD;

    constructor(
        // general info
        uint256 _campaignId,
        address _creator,
        IAdminBeacon _adminBeacon
    ) BaseCampaign(_campaignId, _creator, _adminBeacon) {}
}
