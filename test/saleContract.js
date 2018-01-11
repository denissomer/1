var saleContract = artifacts.require("EWMSaleContract");
var EWMToken = artifacts.require("EWMToken");
var SCRToken = artifacts.require("SCRToken");

var instance_EWM;
var instance_SCR;
var saleContractAddress;
var supply_sale = 40000000000000000000000000;
var num_tokens  = 1000000000000000000000000;

contract('saleContract', function(accounts){
  it("should not have a total supply of 29 million tokens to begin with", function(){
    return saleContract.deployed().then(function(instance){
      saleContractAddress = instance.address;
      return instance.totalSupply();
    }).then(function(supply){
    	console.log("Supply of Sale Contract =", supply.valueOf());
      assert.notEqual(supply.valueOf(), 29000000000000000000000000, "Total supply isn't zero");
    });
  });

  it("should have a supply after approval", function(){
  	EWMToken.deployed().then(function(instance){
  		instance_EWM = instance;
  		// console.log(saleContractAddress);
  		return instance_EWM.approve(saleContractAddress, supply_sale, {from: accounts[0]});
  	}).then(function(){
  		return instance_EWM.allowance.call(accounts[0], saleContractAddress);
  	}).then(function(supply){
      assert.equal(supply.valueOf(), 29000000000000000000000000, "allowance of Sale Contract isn't set properly");
    });
  });

  it("should have EWM balance of account 5 to be 0", function(){
    EWMToken.deployed().then(function(instance){
      return instance.balanceOf.call(accounts[5]);
    }).then(function(balance){
      console.log("Balance of accounts[5] =", balance.toNumber());
      assert.equal(balance.toNumber(), 0, "Balance of Account 5 is not 0");
    });
  });

  it("should have EWM balance of account 6 to be 0", function(){
    EWMToken.deployed().then(function(instance){
      return instance.balanceOf.call(accounts[6]);
    }).then(function(balance){
      console.log("Balance of accounts[6] =", balance.toNumber());
      assert.equal(balance.toNumber(), 0, "Balance of Account 6 is not 0");
    });
  })

  it("should be able to send Ether to the sale contract", function(){
    saleContract.deployed().then(function(sale_instance){
      console.log("Trying to send Ether to this instance = ", sale_instance);
      return sale_instance.sendTransaction({
        from: accounts[6],
        value: web3.toWei(1, "ether"),
        gas: 200000
      });
    }).then(function(result){
      console.log("After sending ether =", result);
    });

    EWMToken.deployed().then(function(ewm_instance){
      return ewm_instance.balanceOf.call(accounts[6], {from: accounts[0]});
    }).then(function(balance){
      console.log("Balance of tokens in account 6 after sending Ether = ", balance.toNumber());
      assert.equal(balance.toNumber(), num_tokens, "EWM Token balance of the account wasn't right after sending Ether")
    });  
  });
});

