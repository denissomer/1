pragma solidity ^0.4.11;

// for test
import "./EWMToken.sol";
import "./SCRtoken.sol";


import "./SafeMath.sol";
import "./Ownable.sol";
import "./Pausable.sol";

contract EWMSaleContract is  Ownable,SafeMath,Pausable {
    EWMToken    ewm;

    // crowdsale parameters
    uint256 public fundingStartTime = 1502193600;
    uint256 public fundingEndTime   = 1504785600;
    uint256 public totalSupply;
    address public ethFundDeposit   = 0x26967201d4D1e1aA97554838dEfA4fC4d010FF6F;      // deposit address for ETH for EWM Fund
    address public ewmFundDeposit   = 0x0053B91E38B207C97CBff06f48a0f7Ab2Dd81449;      // deposit address for EWM reserve
    address public ewmAddress       = 0xf8e386EDa857484f5a12e4B5DAa9984E06E73705;

    bool public isFinalized;                                                            // switched to true in operational state
    uint256 public constant decimals = 18;                                              // #dp in EWM contract
    uint256 public tokenCreationCap;
    uint256 public constant tokenExchangeRate = 1000;                                   // 1000 EWM tokens per 1 ETH
    uint256 public constant minContribution = 0.05 ether;
    uint256 public constant maxTokens = 1 * (10 ** 6) * 10**decimals;
    uint256 public constant MAX_GAS_PRICE = 50000000000 wei;                            // maximum gas price for contribution transactions
 
    function EWMSaleContract() {
        ewm = EWMToken(ewmAddress);
        tokenCreationCap = ewm.balanceOf(ewmFundDeposit);
        isFinalized = false;
    }

    event MintEWM(address from, address to, uint256 val);
    event LogRefund(address ewmexed _to, uint256 _value);

    function CreateEWM(address to, uint256 val) internal returns (bool success){
        MintEWM(ewmFundDeposit,to,val);
        return ewm.transferFrom(ewmFundDeposit,to,val);
    }

    function () payable {    
        createTokens(msg.sender,msg.value);
    }

    /// @dev Accepts ether and creates new EWM tokens.
    function createTokens(address _beneficiary, uint256 _value) internal whenNotPaused {
      require (tokenCreationCap > totalSupply);                                         // CAP reached no more please
      require (now >= fundingStartTime);
      require (now <= fundingEndTime);
      require (_value >= minContribution);                                              // To avoid spam transactions on the network    
      require (!isFinalized);
      require (tx.gasprice <= MAX_GAS_PRICE);

      uint256 tokens = safeMult(_value, tokenExchangeRate);                             // check that we're not over totals
      uint256 checkedSupply = safeAdd(totalSupply, tokens);

      require (ewm.balanceOf(msg.sender) + tokens <= maxTokens);
      
      // DA 8/6/2017 to fairly allocate the last few tokens
      if (tokenCreationCap < checkedSupply) {        
        uint256 tokensToAllocate = safeSubtract(tokenCreationCap,totalSupply);
        uint256 tokensToRefund   = safeSubtract(tokens,tokensToAllocate);
        totalSupply = tokenCreationCap;
        uint256 etherToRefund = tokensToRefund / tokenExchangeRate;

        require(CreateEWM(_beneficiary,tokensToAllocate));                              // Create EWM
        msg.sender.transfer(etherToRefund);
        LogRefund(msg.sender,etherToRefund);
        ethFundDeposit.transfer(this.balance);
        return;
      }
      // DA 8/6/2017 end of fair allocation code

      totalSupply = checkedSupply;
      require(CreateEWM(_beneficiary, tokens));                                         // logs token creation
      ethFundDeposit.transfer(this.balance);
    }
    
    /// @dev Ends the funding period and sends the ETH home
    function finalize() external onlyOwner {
      require (!isFinalized);
      // move to operational
      isFinalized = true;
      ethFundDeposit.transfer(this.balance);                                            // send the eth to EWM multi-sig
    }
}
//
