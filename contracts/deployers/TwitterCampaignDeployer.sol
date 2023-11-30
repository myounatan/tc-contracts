// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "./BaseDeployer.sol";

import "../campaigns/TwitterCampaign.sol";

contract TwitterCampaignDeployer is BaseDeployer {
    constructor(address _factory) BaseDeployer(_factory) {}

    function deployCampaign(
        uint256 _campaignId,
        address _creator,
        //CampaignLib.CampaignType _campaignType,
        IAdminBeacon _adminBeacon
    ) external virtual onlyFactory returns (address contractAddress) {
        TwitterCampaign campaignContract = new TwitterCampaign(
            _campaignId,
            _creator,
            _adminBeacon
        );

        contractAddress = address(campaignContract);
    }
}
