pragma solidity ^0.4.11;

// ================= Ownable Contract start =============================
/*
 * Ownable
 *
 * Base contract with an owner.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
 */
contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}
// ================= Ownable Contract end ===============================

// ================= Safemath Contract start ============================
/* taking ideas from FirstBlood token */
contract SafeMath {

    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x + y;
      assert((z >= x) && (z >= y));
      return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {
      assert(x >= y);
      uint256 z = x - y;
      return z;
    }

    function safeMult(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }
}
// ================= Safemath Contract end ==============================

// ================= ERC20 Token Contract start =========================
/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}
// ================= ERC20 Token Contract end ===========================

// ================= Standard Token Contract start ======================
contract StandardToken is ERC20, SafeMath {

  /**
   * @dev Fix for the ERC20 short address attack.
   */
  modifier onlyPayloadSize(uint size) {
     require(msg.data.length >= size + 4) ;
     _;
  }

  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32)  returns (bool success){
    balances[msg.sender] = safeSubtract(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) returns (bool success) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because safeSub(_allowance, _value) will already throw if this condition is not met
    // if (_value > _allowance) throw;

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSubtract(balances[_from], _value);
    allowed[_from][msg.sender] = safeSubtract(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}
// ================= Standard Token Contract end ========================

// ================= Pausable Token Contract start ======================
/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require (!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require (paused) ;
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}
// ================= Pausable Token Contract end ========================

// ================= EWM Token Contract start =======================
contract EWMToken is SafeMath, StandardToken, Pausable {
    // metadata
    string public constant name = "Electron World Money";
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
// ================= EWM Token Contract end =======================

// ================= Actual Sale Contract Start ====================
contract EWMSaleContract is  Ownable,SafeMath,Pausable {
    EWMToken    ewm;

    // crowdsale parameters
    uint256 public fundingStartTime = 1517140800;
    uint256 public fundingEndTime   = 1517745600;
    uint256 public totalSupply;
    address public ethFundDeposit   = 0x26967201d4D1e1aA97554838dEfA4fC4d010FF6F;      // deposit address for ETH for EWM Fund
    address public ewmFundDeposit   = 0x0053B91E38B207C97CBff06f48a0f7Ab2Dd81449;      // deposit address for EWM reserve
    address public ewmAddress       = 0xf8e386EDa857484f5a12e4B5DAa9984E06E73705;

    bool public isFinalized;                                                            // switched to true in operational state
    uint256 public constant decimals = 18;                                              // #dp in EWM contract
    uint256 public tokenCreationCap;
    uint256 public constant tokenExchangeRate = 6000;                                   // 6000 EWM tokens per 1 ETH
    uint256 public constant minContribution = 0.01 ether;
    uint256 public constant maxTokens = 1 * (10 ** 6) * 10**decimals;
    uint256 public constant MAX_GAS_PRICE = 50000000000 wei;                            // maximum gas price for contribution transactions
 
    function EWMSaleContract() {
        ewm = EWMToken(ewmAddress);
        tokenCreationCap = ewm.balanceOf(ewmFundDeposit);
        isFinalized = false;
    }

    event MintEWM(address from, address to, uint256 val);
    event LogRefund(address indexed _to, uint256 _value);

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
      
      // DA 1/2/2018 to fairly allocate the last few tokens
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
      // DA 1/2/2018 end of fair allocation code

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
