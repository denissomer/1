// // Specifically request an abstraction for MetaCoin
var EWMToken = artifacts.require("EWMToken");

var num_tokens = 2163 * Math.pow(10,23);
var ewmFundDeposit_balance = 301 * Math.pow(10,23);

contract('EWMToken', function(accounts){
  it("should have a total supply of x million tokens", function(){
    return EWMToken.deployed().then(function(instance){
      return instance.totalSupply();
    }).then(function(supply){
    	// console.log(supply.valueOf());
      assert.equal(supply.valueOf(), num_tokens, "Total supply isn't zero");
    });
  });

  it("should have ewmFundDeposit set as account 0", function(){
  	return EWMToken.deployed().then(function(instance){
  		return instance.ewmFundDeposit();
  	}).then(function(address){
  		// console.log("ewmFundDeposit address = ", address);
  		assert.equal(address, accounts[0]);
  	});
  });

  // it("ewmFundDeposit should have a supply of 30.1 million tokens", function(){
  // 	return EWMToken.deployed().then(function(instance){
  // 		console.log(instance.address);
  // 		console.log(accounts[0]);
  // 		return instance.balanceOf.call(accounts[0], {from: accounts[0]});
  // 	}).then(function(balance){
  // 		console.log("Balance of ewmFundDeposit =", balance.toNumber());
  // 		assert.equal(balance.toNumber(), ewmFundDeposit_balance);
  // 	});
  // });
});
//
