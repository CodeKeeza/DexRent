pragma solidity >=0.8.0 <0.9.0;
pragma abicoder v2;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./Administration.sol";
import "./RentToken.sol";
import "./DataBank.sol";
import "hardhat/console.sol";

contract RentManager is RentToken, Administration, DataBank {
  using Counters for Counters.Counter;
  Counters.Counter private renterCount;
  Counters.Counter private renteeCount;
  Counters.Counter private propertyCount;

  address owner;
  address operator;
  address manager;
  
  uint256 NULL_VALUE = 9999999999999;

  modifier RenterExists(uint256 _renterID) {
    uint count = renterCount.current();
    require(_renterID <= count, "Invalid RenterID provided");
    _;
  }
  modifier RenteeExists(uint256 _renteeID) {
    uint count = renteeCount.current();
    require(_renteeID <= count, "Invalid RenteeID provided");
    _;
  }
  modifier PropertyExists(uint256 _propertyID) {
    uint count = propertyCount.current();
    require(_propertyID <= count, "Invalid PropertyID provided");
    _;
  }

  constructor() {
    _setupRole(APP_DEV, msg.sender);
    owner = payable(msg.sender);
    operator = payable(msg.sender);
    manager = payable(msg.sender);
  }
  /// Adding Functions
  function addRentee(address[] calldata _renteeWallets, address[] calldata _admins) public returns (bool result) {
    require(_renteeWallets.length > 0, "No Wallet Entered");
    require(_admins.length > 0, "No Admin Entered");
    renteeCount.increment();
    uint256 count = renteeCount.current();
    RENTEES[count].renteeWallets = _renteeWallets;
    RENTEES[count].monthlyRentDue = 0;
    RENTEES[count].arrearsOwed = 0;
    RENTEES[count].renteeID = count;
    RENTEES[count].admins = _admins;
    return result;
  }
  function addRenter(address[] calldata _renterWallets, address[] calldata _admins) public returns (bool result) {
    require(_renterWallets.length > 0, "No Wallet Entered");
    require(_admins.length > 0, "No Admin Entered");
    renterCount.increment();
    uint count = renterCount.current();
    RENTERS[count].renterWallets = _renterWallets;
    RENTERS[count].admins = _admins;
    RENTERS[count].renterID = count;
    RENTERS[count].inDebt = false;
    return result;
  }
  function addProperty(string calldata _identifier, string calldata _streetName, string calldata _postcode, uint256 _rent, address[] calldata _admins) public returns (bool result) {
    require(_admins.length > 0, "No Admin Entered");
    require(_rent > 0, "No Rent Entered");
    propertyCount.increment();
    uint count = propertyCount.current();
    PROPERTIES[count].identifier = _identifier;
    PROPERTIES[count].streetName = _streetName;
    PROPERTIES[count].postcode = _postcode;
    PROPERTIES[count].rent = _rent;
    PROPERTIES[count].admins = _admins;
    PROPERTIES[count].propertyID = count;
    PROPERTIES[count].inDefault = false;
    return result;

  }
  function addRenteeToProperty(uint256 _renteeID, uint256 _propertyID) public RenteeExists(_renteeID) PropertyExists(_propertyID) returns (bool result) {
    Property storage currentProperty = PROPERTIES[_propertyID];
    Rentee storage currentRentee = RENTEES[_renteeID];
    require(currentProperty.isDeleted == false, "prop is deleted");
    require(currentRentee.isDeleted == false, "rentee is deleted");
    currentProperty.renteeID = uint256(_renteeID);
    currentProperty.admins = currentRentee.admins;
    currentRentee.ownedProperties.push(_propertyID);
    currentRentee.monthlyRentDue += currentProperty.rent;
    return result;
  }

  function addPropertyToRentee(uint _propertyID, uint _renteeID) public PropertyExists(_propertyID) RenteeExists(_renteeID) returns (bool result) {
    Property storage currentProperty = PROPERTIES[_propertyID];
    Rentee storage currentRentee = RENTEES[_renteeID];
    require(currentProperty.isDeleted == false, "prop is deleted");
    require(currentRentee.isDeleted == false, "rentee is deleted");
    currentRentee.ownedProperties.push(_propertyID);
    currentProperty.renteeID = _renteeID;
    return result;
  }

  function addRenterToProperty(uint _renterID, uint _propertyID) public RenterExists(_renterID) PropertyExists(_propertyID) returns (bool result) {
    Property storage currentProperty = PROPERTIES[_propertyID];
    Renter storage currentRenter = RENTERS[_renterID];
    require(currentProperty.isDeleted == false, "prop is deleted");
    require(currentRenter.isDeleted == false, "renter is deleted");
    currentProperty.renterID = uint256(_renterID);
    currentProperty.rent = currentRenter.rent;
    currentRenter.propertyID = currentProperty.propertyID;
    currentRenter.paymentStatus = currentProperty.paymentStatus;
    currentRenter.inDebt = currentProperty.inDefault;
    return result;
  }

  // Removing Functions
  function removeRentee(uint _renteeID) public RenteeExists(_renteeID) onlyRole(APP_DEV) returns(bool result) {
    Rentee storage currentRentee = RENTEES[_renteeID];
    require(currentRentee.isDeleted == false, "rentee is already deleted");
    currentRentee.isDeleted = true;
    delete currentRentee.renteeWallets;
    delete currentRentee.admins;
    delete currentRentee.ownedProperties;
    delete currentRentee.monthlyRentDue;
    delete currentRentee.arrearsOwed;
    delete currentRentee.renteeID;
    return result;
  }
  function removeRenter(uint _renterID) public RenterExists(_renterID) onlyRole(APP_DEV) onlyRole(RENTEE_ROLE) returns(bool result) {
    Renter storage currentRenter = RENTERS[_renterID];
    require(currentRenter.isDeleted == false, "renter is already deleted");
    currentRenter.isDeleted = true;
    delete currentRenter.renterWallets;
    delete currentRenter.admins;
    delete currentRenter.arrears;
    delete currentRenter.rent;
    delete currentRenter.weeksMissed;
    delete currentRenter.renterID;
    delete currentRenter.propertyID;
    delete currentRenter.inDebt;
    return result;
  }
  function removeProperty(uint _propertyID) public PropertyExists(_propertyID) onlyRole(RENTEE_ROLE) onlyRole(APP_DEV) returns(bool result) {
    Property storage currentProperty = PROPERTIES[_propertyID];
    require(currentProperty.isDeleted == false, "prop is already deleted");
    currentProperty.isDeleted = true;
    delete currentProperty.identifier;
    delete currentProperty.streetName;
    delete currentProperty.postcode;
    delete currentProperty.rent;
    delete currentProperty.renteeID;
    delete currentProperty.renterID;
    delete currentProperty.propertyID;
    delete currentProperty.admins;
    delete currentProperty.inDefault;
    delete currentProperty.isDeleted;
    delete currentProperty.paymentStatus;
    return result;
  }
  function removeRenteeFromProperty(uint _renteeID, uint _propertyID) public RenteeExists(_renteeID) PropertyExists(_propertyID) onlyRole(APP_DEV) returns(bool result) {
    Property storage currentProperty = PROPERTIES[_propertyID];
    Rentee storage currentRentee = RENTEES[_renteeID];
    require(currentProperty.isDeleted == false, "prop is deleted");
    require(currentRentee.isDeleted == false, "renter is deleted");
    delete currentProperty.renteeID;
    return result;
  }
  function removeRenterFromProperty(uint _renterID, uint _propertyID) public RenterExists(_renterID) PropertyExists(_propertyID) onlyRole(RENTEE_ROLE) onlyRole(APP_DEV) returns(bool result) {
    Property storage currentProperty = PROPERTIES[_propertyID];
    Renter storage currentRenter = RENTERS[_renterID];
    require(currentProperty.isDeleted == false, "prop is deleted");
    require(currentRenter.isDeleted == false, "renter is deleted");
    delete currentProperty.renterID;
    return result;    
  }
  function removeAdminFromProperty(uint _propertyID, uint _admin) public returns(bool result) {
    Property storage currentProperty = PROPERTIES[_propertyID];
    require(currentProperty.isDeleted == false, "prop is deleted");
    currentProperty.admins[_admin] = operator;
    return result;
  }
  function removePropertyFromRentee(uint _propertyID, uint _renteeID) public PropertyExists(_propertyID) RenteeExists(_renteeID) onlyRole(RENTEE_ROLE) onlyRole(APP_DEV) returns(bool result) {
    Property storage currentProperty = PROPERTIES[_propertyID];
    Rentee storage currentRentee = RENTEES[_renteeID];
    // need to remove property from array of rentee properties
    delete currentProperty.renteeID;
    return result;
  }
  function removePropertyFromRenter(uint _propertyID, uint _renterID) public PropertyExists(_propertyID) RenterExists(_renterID) onlyRole(RENTEE_ROLE) onlyRole(APP_DEV) {

  }
  /// Getter functions
  function getPropertyRentee(uint _propertyID) public view PropertyExists(_propertyID) returns (Rentee memory) {
    Property storage currentProperty = PROPERTIES[_propertyID];
    uint rentee = currentProperty.renteeID;
    Rentee storage propertyRentee = RENTEES[rentee];
    return (propertyRentee);
  }
  function getPropertyRenter(uint _propertyID) public view PropertyExists(_propertyID) returns (Renter memory) {
    Property storage currentProperty = PROPERTIES[_propertyID];
    uint renter = currentProperty.renterID;
    Renter storage propertyRenter = RENTERS[renter];
    return (propertyRenter);
  }
  function getRenterProperty(uint _renterID) public view RenterExists(_renterID) returns (Property memory) {
    Renter storage currentRenter = RENTERS[_renterID];
    uint propertyID = currentRenter.propertyID;
    Property storage renterProperty = PROPERTIES[propertyID];
    return (renterProperty);
  }
  function getRenteeProperty(uint _renteeID, uint _propertyID) public view RenteeExists(_renteeID) PropertyExists(_propertyID) returns (string memory, string memory, string memory, uint, uint, address[] memory, bool, PaymentStatus) {
    Property storage renteeProperty = PROPERTIES[_propertyID];
    require(renteeProperty.renteeID == _renteeID);
    return (renteeProperty.identifier, renteeProperty.streetName, renteeProperty.postcode, renteeProperty.rent, renteeProperty.renterID, renteeProperty.admins, renteeProperty.inDefault, renteeProperty.paymentStatus);
  }
  function getRenter(uint _renterID) public view RenterExists(_renterID) returns (Renter memory) {
    Renter storage currentRenter = RENTERS[_renterID];
    return (currentRenter);
  }
  function getRentee(uint _renteeID) public view RenteeExists(_renteeID) returns (Rentee memory) {
    Rentee storage currentRentee = RENTEES[_renteeID];
    return (currentRentee);
  }
  function getProperty(uint _propertyID) public view PropertyExists(_propertyID) returns (Property memory) {
    Property storage currentProperty = PROPERTIES[_propertyID];
    return (currentProperty);
  }
  function getRenterCount() public view returns (uint) {
      uint count = renterCount.current();
      return count;
  }
  function getRenteeCount() public view returns (uint) {
      uint count = renteeCount.current();
      return count;
  }
  function getPropertyCount() public view returns (uint) {
      uint count = propertyCount.current();
      return count;
  }
  function getRenterRentAmount(uint _renterID) public view RenterExists(_renterID) returns (uint) {
    Renter storage renter = RENTERS[_renterID];
    uint rent = renter.rent;
    return rent; 
  }
  function getPropertyRentAmount(uint _propertyID) public view PropertyExists(_propertyID) returns (uint) {
    Property storage property = PROPERTIES[_propertyID];
    uint rent = property.rent;
    return rent; 
  }
}
