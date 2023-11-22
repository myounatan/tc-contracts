// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// create a test erc20 with 6 digits of precision like USDC

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../admin/IAdminBeacon.sol";

contract TestUSD is ERC20 {
    IAdminBeacon private adminBeacon;

    error OnlyAdmin();

    modifier onlyAdmin() {
        if (msg.sender != adminBeacon.getAdmin()) revert OnlyAdmin();
        _;
    }

    constructor(IAdminBeacon _adminBeacon) ERC20("TestUSD", "TUSD") {
        adminBeacon = _adminBeacon;
    }

    function decimals() public view virtual override returns (uint8) {
        return 6; // like USDC
    }

    // admin minting
    function mint(address to, uint256 amount) external onlyAdmin {
        _mint(to, amount);
    }
}
