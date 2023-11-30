// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./IBaseDeployer.sol";

import "../admin/IAdminBeacon.sol";

abstract contract BaseDeployer is IBaseDeployer, Ownable {
    address private factory;

    modifier onlyFactory() {
        if (msg.sender != factory) revert OnlyFactory();
        _;
    }

    constructor(address _factory) {
        _setFactory(_factory);
    }

    function _setFactory(address _factory) internal {
        factory = _factory;
    }

    function setFactory(address _factory) external virtual override onlyOwner {
        _setFactory(_factory);
    }

    function getFactory() external view virtual override returns (address) {
        return factory;
    }
}
