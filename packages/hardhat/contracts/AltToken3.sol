// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AltToken3 is ERC20 {

    constructor(address _who) ERC20("AltToken3", "ALT3") {
        _mint(_who, 1000000000000);
    }
}
