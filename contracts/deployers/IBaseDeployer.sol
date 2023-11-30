// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "../admin/IAdminBeacon.sol";

import "../CampaignLib.sol";

interface IBaseDeployer {
    error OnlyFactory();

    function setFactory(address _factory) external;

    function getFactory() external view returns (address);

    function deployCampaign(
        uint256 _campaignId,
        address _creator,
        //CampaignLib.CampaignType _campaignType,
        IAdminBeacon _adminBeacon
    ) external returns (address);
}
