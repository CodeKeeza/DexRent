// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RentToken is ERC20 {

    constructor() ERC20("RentToken", "Rent") {
        _mint(msg.sender, 1000000000000);
    }
}
