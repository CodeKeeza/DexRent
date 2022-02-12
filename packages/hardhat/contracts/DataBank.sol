// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Administration.sol";

contract DataBank is Administration {
  
  address[] paymentTokens;

  uint256 weekPeriod = 604800;
  uint256 monthPeriod = 2592000;

  enum PaymentStatus{NOTDUE, DUE, OVERDUE}

  mapping(uint256 => Renter) internal RENTERS; // Renter identifier
  mapping(uint256 => Rentee) internal RENTEES; // Renter identifier
  mapping(uint256 => Property) internal PROPERTIES; // Property identifier
  mapping(uint256 => Property) internal ownedProperties; // 0 index of owned property
  mapping(uint256 => mapping(PaymentStatus => Property)) internal _propertyRentStatus; // status of current month's rent for user
  mapping(uint256 => mapping(PaymentStatus => Renter)) internal _renterRentStatus; // status of current month's rent

  struct Renter {
    address[] renterWallets; // array of user wallets
    address[] admins; // array of admin addresses
    uint256 arrears; // rent owed
    uint256 rent; // rent amount
    uint256 weeksMissed; // how many weeks in arrears
    uint256 renterID; // renter identifier
    uint256 propertyID; // Property Identifier
    bool inDebt; // Yes or No, quick identifier
    bool isDeleted; // Yes or No, has the Renter been removed
    PaymentStatus paymentStatus;
  }

  struct Rentee {
    address[] renteeWallets; // array of rentee wallets
    address[] admins; // array of admin addresses
    uint256[] ownedProperties; // owned properties
    uint256 monthlyRentDue; // amount due each month = property.rent * rent / 12 * ownedProperties
    uint256 arrearsOwed; // arrears owed = renter.weeksMissed * rent(weekPeriod).propertyID
    uint256 renteeID; // Rentee identifier
    bool isDeleted; // Yes or No, has the Rentee been removed

  }

  struct Property {
    string identifier; // house name or number
    string streetName; // street name
    string postcode; // zip code
    uint256 rent; // monthly rent amount
    uint256 renteeID; // Rentee Identifier
    uint256 renterID; // Renter Identifier
    uint256 propertyID; // Property Identifier
    address[] admins; // array of admin addresses
    bool inDefault; // Yes or No, quick identifier
    bool isDeleted; // Yes or No, has the property been removed
    PaymentStatus paymentStatus;
  }
}