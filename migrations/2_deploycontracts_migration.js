var SCRToken = artifacts.require("./SCRToken.sol");
var EWMToken = artifacts.require("./EWMToken.sol");
var EWMSaleContract = artifacts.require("./EWMSaleContract.sol");

var _ewmFundDeposit = "0xb93489b75a0cf3bf5a380ab3c986482d15a9ef56",
    _ewmFutureDeposit = "0xb93489b75a0cf3bf5a380ab3c986482d15a9ef56",
    _ewmPresaleDeposit = "0xb93489b75a0cf3bf5a380ab3c986482d15a9ef56",
    _ewmInflationDeposit = "0xb93489b75a0cf3bf5a380ab3c986482d15a9ef56"

var _ethFundDeposit = "0xb93489b75a0cf3bf5a380ab3c986482d15a9ef56",
    _EWMtoken, 
    _fundingStartTime = 1517140800,
    duration = 20;

var EWMAddress, SCRAddress, SaleContractAddress;

module.exports = function(deployer){
	// console.log("Deploying EWM");
	deployer.deploy(EWMToken, _ewmFundDeposit, _ewmFutureDeposit, _ewmPresaleDeposit, _ewmInflationDeposit).then(function() {
		EWMAddress = EWMToken.address;
		console.log("EWM address = ", EWMAddress);
		return deployer.deploy(EWMSaleContract, _ethFundDeposit, _ewmFundDeposit, EWMAddress, _fundingStartTime, duration).then(function(instance2){
			console.log("Deployed EWMSaleContract");
	  		console.log("Sale Contract address = ", EWMSaleContract.address);
		});
  	});
}
