// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

abstract contract IAdminBeacon {
    function getAdmin() external view virtual returns (address);
}
