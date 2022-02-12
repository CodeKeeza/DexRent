// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Administration is AccessControl {
  bytes32 internal constant RENTER_ROLE = keccak256("RENTER");
  bytes32 internal constant RENTEE_ROLE = keccak256("RENTEE");

  /// @dev Add `root` to the admin role as a member.
  constructor ()
  {
    _setupRole(APP_DEV, tx.origin);
    _setRoleAdmin(RENTER_ROLE, APP_DEV);
    _setRoleAdmin(RENTEE_ROLE, APP_DEV);
  }
  /// @dev Restricted to members of the admin role.
  modifier onlyAdmin()
  {
    require(isAdmin(msg.sender), "Restricted to admins.");
    _;
  }
  /// @dev Restricted to members of the user role.
  modifier onlyRenter()
  {
    require(isRenter(msg.sender), "Restricted to Renters.");
    _;
  }
    modifier onlyRentee()
  {
    require(isRentee(msg.sender), "Restricted to Rentees.");
    _;
  }
  /// @dev Return `true` if the account belongs to the admin role.
  function isAdmin(address account)
    internal view returns (bool)
  {
    return hasRole(APP_DEV, account);
  }
  /// @dev Return `true` if the account belongs to the user role.
  function isRenter(address account)
    internal view returns (bool)
  {
    return hasRole(RENTER_ROLE, account);
  }
  function isRentee(address account)
    internal view returns (bool)
  {
    return hasRole(RENTEE_ROLE, account);
  }
  /// @dev Add an account to the user role. Restricted to admins.
  function addRenterRole(address account)
    internal onlyAdmin
  {
    grantRole(RENTER_ROLE, account);
  }
  function addRenteeRole(address account)
    internal onlyAdmin
  {
    grantRole(RENTEE_ROLE, account);
  }
  /// @dev Add an account to the admin role. Restricted to admins.
  function addAdmin(address account)
    internal onlyAdmin
  {
    grantRole(APP_DEV, account);
  }
  /// @dev Remove an account from the user role. Restricted to admins.
  function removeRenter(address account)
    internal onlyAdmin
  {
    revokeRole(RENTER_ROLE, account);
  }
  function removeRentee(address account)
    internal onlyAdmin
  {
    revokeRole(RENTEE_ROLE, account);
  }
  /// @dev Remove oneself from the admin role.
  function renounceAdmin()
    internal
  {
    renounceRole(APP_DEV, msg.sender);
  }
}