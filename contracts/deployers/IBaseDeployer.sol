// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "../admin/IAdminBeacon.sol";

interface IBaseDeployer {
    error OnlyFactory();

    function setFactory(address _factory) external;

    function getFactory() external view returns (address);

    function deployCampaign(
        uint256 campaignId,
        address creator,
        IAdminBeacon adminBeacon
    ) external returns (address);
}
