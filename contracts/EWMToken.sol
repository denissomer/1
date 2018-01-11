pragma solidity ^0.4.11;
import "./StandardToken.sol";
import "./SafeMath.sol";
import "./Pausable.sol";

contract EWMToken is SafeMath, StandardToken, Pausable {
    // metadata
    string public constant name = "EWM Token";
    string public constant symbol = "EWM";
    uint256 public constant decimals = 18;
    string public version = "1.0";

    // contracts
    address public ewmSaleDeposit        = 0x0053B91E38B207C97CBff06f48a0f7Ab2Dd81449;      // deposit address for EWM Sale contract
    address public ewmSeedDeposit        = 0x0083fdFB328fC8D07E2a7933e3013e181F9798Ad;      // deposit address for EWM Seed Contributors
    address public ewmPresaleDeposit     = 0x007AB99FBf023Cb41b50AE7D24621729295EdBFA;      // deposit address for EWM Presale Contributors
    address public ewmVestingDeposit     = 0x0011349f715cf59F75F0A00185e7B1c36f55C3ab;      // deposit address for EWM Vesting for team and advisors
    address public ewmCommunityDeposit   = 0x0097ec8840E682d058b24E6e19E68358d97A6E5C;      // deposit address for EWM Marketing, etc
    address public ewmFutureDeposit      = 0x00d1bCbCDE9Ca431f6dd92077dFaE98f94e446e4;      // deposit address for EWM Future token sale
    address public ewmInflationDeposit   = 0x00D31206E625F1f30039d1Fa472303E71317870A;      // deposit address for EWM Inflation pool
    
    uint256 public constant ewmSale      = 31603785 * 10**decimals;                         
    uint256 public constant ewmSeed      = 3566341  * 10**decimals; 
    uint256 public constant ewmPreSale   = 22995270 * 10**decimals;                       
    uint256 public constant ewmVesting   = 28079514 * 10**decimals;  
    uint256 public constant ewmCommunity = 10919811 * 10**decimals;  
    uint256 public constant ewmFuture    = 58832579 * 10**decimals;  
    uint256 public constant ewmInflation = 14624747 * 10**decimals;  
   
    // constructor
    function EWMToken()
    {
      balances[ewmSaleDeposit]           = ewmSale;                                         // Deposit EWM share
      balances[ewmSeedDeposit]           = ewmSeed;                                         // Deposit EWM share
      balances[ewmPresaleDeposit]        = ewmPreSale;                                      // Deposit EWM future share
      balances[ewmVestingDeposit]        = ewmVesting;                                      // Deposit EWM future share
      balances[ewmCommunityDeposit]      = ewmCommunity;                                    // Deposit EWM future share
      balances[ewmFutureDeposit]         = ewmFuture;                                       // Deposit EWM future share
      balances[ewmInflationDeposit]      = ewmInflation;                                    // Deposit for inflation

      totalSupply = ewmSale + ewmSeed + ewmPreSale + ewmVesting + ewmCommunity + ewmFuture + ewmInflation;

      Transfer(0x0,ewmSaleDeposit,ewmSale);
      Transfer(0x0,ewmSeedDeposit,ewmSeed);
      Transfer(0x0,ewmPresaleDeposit,ewmPreSale);
      Transfer(0x0,ewmVestingDeposit,ewmVesting);
      Transfer(0x0,ewmCommunityDeposit,ewmCommunity);
      Transfer(0x0,ewmFutureDeposit,ewmFuture);
      Transfer(0x0,ewmInflationDeposit,ewmInflation);
   }

  function transfer(address _to, uint _value) whenNotPaused returns (bool success)  {
    return super.transfer(_to,_value);
  }

  function approve(address _spender, uint _value) whenNotPaused returns (bool success)  {
    return super.approve(_spender,_value);
  }
}
//
