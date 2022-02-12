// deploy/00_deploy_your_contract.js

const { ethers } = require('hardhat')

const localChainId = '31337'

const sleep = (ms) =>
  new Promise((r) =>
    setTimeout(() => {
      // console.log(`waited for ${(ms / 1000).toFixed(3)} seconds`);
      r()
    }, ms),
  )

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments
  const { deployer } = await getNamedAccounts()
  const chainId = await getChainId()

  await deploy('RentManager', {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    // args: [ "Hello", ethers.utils.parseEther("1.5") ],
    log: true,
  })

  // Getting a previously deployed contract
  const RentManager = await ethers.getContract('RentManager', deployer)
  const RentManagerInstance = await ethers.getContractAt(
    'RentManager',
    RentManager.address,
  ) //<-- if you want to instantiate a version of a contract at a specific address!

  const renteeAdded = await RentManagerInstance.addRentee(
    [deployer],
    [deployer],
  )
  const rentee2Added = await RentManagerInstance.addRentee(
    [deployer],
    [deployer],
  )
  const rentee3Added = await RentManagerInstance.addRentee(
    [deployer],
    [deployer],
  )
  const rentee4Added = await RentManagerInstance.addRentee(
    [deployer],
    [deployer],
  )

  const renterAdded = await RentManagerInstance.addRenter(
    [deployer],
    [deployer],
  )
  const renter2Added = await RentManagerInstance.addRenter(
    [deployer],
    [deployer],
  )
  const renter3Added = await RentManagerInstance.addRenter(
    [deployer],
    [deployer],
  )
  const renter4Added = await RentManagerInstance.addRenter(
    [deployer],
    [deployer],
  )
  // console.log("renterAdded" + JSON.stringify(renterAdded))
  // const renter = await RentManagerInstance.getRenter(1)
  // console.log("renter:" + JSON.stringify(renter))
  // const rentee = await RentManagerInstance.getRentee(1)
  // console.log("rentee:" + JSON.stringify(rentee))
  const propertyAdded = await RentManagerInstance.addProperty(
    '7F',
    'Newton Street',
    'PA168UH',
    450,
    [deployer],
  )
  console.log('property one added:' + propertyAdded)
  const property2Added = await RentManagerInstance.addProperty(
    '16',
    'Wiseman Street',
    'PA28UH',
    1500,
    [deployer],
  )
  console.log('property two added:' + property2Added)
  const property3Added = await RentManagerInstance.addProperty(
    'Chester House',
    'Fucking Street',
    'PUH232',
    2100,
    [deployer],
  )
  console.log('property three added:' + property3Added)
  const property4Added = await RentManagerInstance.addProperty(
    '02F',
    'Wholesome lane',
    'PUH232',
    1200,
    [deployer],
  )
  console.log('property four added:' + property4Added)
  const property5Added = await RentManagerInstance.addProperty(
    '1A',
    'Shoutout circle',
    'PUH232',
    900,
    [deployer],
  )
  console.log('property five added:' + property5Added)

  const renteeAddedToProperty = await RentManagerInstance.addRenteeToProperty(
    '1',
    '1',
  )
  console.log('rentee one added to property one:' + renteeAddedToProperty)
  const grabRenteeProp = await RentManagerInstance.getRenteeProperty('1', '1')
  console.log('rentee one property one:' + grabRenteeProp)
  const rentee1AddedToProperty = await RentManagerInstance.addRenteeToProperty(
    '1',
    '2',
  )
  console.log('rentee 1 added to property two:' + rentee1AddedToProperty)
  const grabRentee2Prop = await RentManagerInstance.getRenteeProperty('1', '2')
  console.log('rentee one property two:' + grabRentee2Prop)

  const rentee2AddedToProperty = await RentManagerInstance.addRenteeToProperty(
    '2',
    '3',
  )
  console.log('rentee two added to property three:' + rentee2AddedToProperty)

  const grabRentee3Prop = await RentManagerInstance.getRenteeProperty('2', '3')
  console.log('rentee two property one:' + grabRentee3Prop)

  const renterAddedToProperty = await RentManagerInstance.addRenterToProperty(
    '1',
    '1',
  )
  console.log('renter one added to property one:' + renterAddedToProperty)
  const grabRenterProp = await RentManagerInstance.getRenterProperty('1')
  console.log('renter one property:' + grabRenterProp)
  const renter2AddedToProperty = await RentManagerInstance.addRenterToProperty(
    '2',
    '2',
  )
  console.log('renter two added to property two:' + renter2AddedToProperty)
  const grabRenter2Prop = await RentManagerInstance.getRenterProperty('2')
  console.log('renter two property:' + grabRenter2Prop)
  const renter3AddedToProperty = await RentManagerInstance.addRenterToProperty(
    '3',
    '3',
  )
  console.log('renter three added to property three:' + renter3AddedToProperty)
  const grabRenter3Prop = await RentManagerInstance.getRenterProperty('3')
  console.log('renter two property:' + grabRenter3Prop)
  const renterRent = await RentManagerInstance.getRenterRentAmount('1')
  console.log('Renter one rent amount: ' + renterRent)

  console.log('complete')
  /*
  //If you want to send value to an address from the deployer
  const deployerWallet = ethers.provider.getSigner()
  await deployerWallet.sendTransaction({
    to: "0x34aA3F359A9D614239015126635CE7732c18fDF3",
    value: ethers.utils.parseEther("0.001")
  })
  */

  /*
  //If you want to send some ETH to a contract on deploy (make your constructor payable!)
  const RentManager = await deploy("RentManager", [], {
  value: ethers.utils.parseEther("0.05")
  });
  */

  /*
  //If you want to link a library into your contract:
  // reference: https://github.com/austintgriffith/scaffold-eth/blob/using-libraries-example/packages/hardhat/scripts/deploy.js#L19
  const RentManager = await deploy("RentManager", [], {}, {
   LibraryName: **LibraryAddress**
  });
  */

  // Verify your contracts with Etherscan
  // You don't want to verify on localhost
  if (chainId !== localChainId) {
    // wait for etherscan to be ready to verify
    await sleep(15000)
    await run('verify:verify', {
      address: RentManager.address,
      contract: 'contracts/RentManager.sol:RentManager',
      contractArguments: [],
    })
  }
}
module.exports.tags = ['RentManager']
