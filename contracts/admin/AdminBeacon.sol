// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./IAdminBeacon.sol";

// TODO: make this upgradeable with transparent proxy? might be useful to add more logic. but it is pretty barebones anyways
contract AdminBeacon is IAdminBeacon, Ownable {
    address private backendAdmin;

    constructor(address _backendAdmin) {
        _setAdmin(_backendAdmin);
    }

    function _setAdmin(address _backendAdmin) internal {
        backendAdmin = _backendAdmin;
    }

    function setAdmin(address _backendAdmin) external onlyOwner {
        _setAdmin(_backendAdmin);
    }

    function getAdmin() external view virtual override returns (address) {
        return backendAdmin;
    }
}
