// SPDX-License-Identifier: MIT
// Code by DEMANGEL DAMIEN 1977
// PERFECT DEFI TOKEN PAYABLE-STAKING-REWARD-BURNABLE-MINTABLE-SECURE-UTILITY
pragma solidity ^0.5.8;

contract Pausable {
    bool private _paused;

    event Paused(address account);
    event Unpaused(address account);

    constructor() public {
    _paused = false;
}

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function pause() external {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    function paused() public view returns (bool) {
        return _paused;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

contract ERC20 is IBEP20, Pausable {
    using SafeMath for uint256;

    uint256 private _totalSupply;
    uint8 private _decimals;


    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(string memory /*_name*/, string memory /*_symbol*/) public {
    // Initialize the contract with the creator of the contract
    _mint(msg.sender, 1000000000); // Initial supply
    _decimals = 2;
}

    function name() external view returns (string memory) {
    return "BITCOIN-X REVOLUTION";
}

   function symbol() external view returns (string memory) {
        return "BITCOIN";
    }

   function decimals() external view returns (uint8) {
    return _decimals;
}

function getDecimals() external view  returns (uint8) {
   return _decimals; 
    }

    function getOwner() external view  returns (address) {
        // Add implementation here
    }

    function tokenName() external view returns (string memory) {
        // Add implementation here
    }

    function tokenSymbol() external view returns (string memory) {
        // Add implementation here
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public whenNotPaused  returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowances[from][msg.sender].sub(value));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function burn(uint256 amount) public whenNotPaused {
        _burn(msg.sender, amount);
    }

    function mint(uint256 amount) public whenNotPaused {
        _mint(msg.sender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");

        _balances[sender] -= amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;

        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        require(_balances[account] >= amount, "ERC20: burn amount exceeds balance");

        _balances[account] -= amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }
}

contract StakingToken is ERC20 {
    using SafeMath for uint256;

    address public constant TOKEN_CONTRACT_ADDRESS = 0xD6F5284239C2C11635A349fB55A8e207064a7380; // First Bitcoin-x Contract
    address public constant OWNER_WALLET = 0x12320E4eee46419c40af2e06013AF16Ea0adaFa4; // Owners adress

    uint256 public constant REWARD_RATE = 1;
    uint256 public constant REWARD_INTERVAL = 1 days;

    uint256 public rewardRate;

    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public lastStakeTime;

    event Staked(address indexed staker, uint256 amount);
    event Unstaked(address indexed staker, uint256 amount);

    constructor() public ERC20("BITCOIN-X REVOLUTION", "BITCOIN") {
    _mint(OWNER_WALLET, 1000000000);
}

   function symbol() external view returns (string memory) {
    return "BITCOIN";
}
    function receiveEther() external {
        // Gérez l'Ether entrant si nécessaire
    }

    function stake(uint256 amount) external whenNotPaused {
        require(msg.sender == TOKEN_CONTRACT_ADDRESS || msg.sender == OWNER_WALLET, "Unauthorized");

        _updateReward(msg.sender);
        _mint(msg.sender, amount);
        stakingBalance[msg.sender] = stakingBalance[msg.sender].add(amount);
        lastStakeTime[msg.sender] = block.timestamp;
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external whenNotPaused {
        require(msg.sender == TOKEN_CONTRACT_ADDRESS || msg.sender == OWNER_WALLET, "Unauthorized");

        _updateReward(msg.sender);
        require(stakingBalance[msg.sender] >= amount, "Insufficient balance for withdrawal");

        stakingBalance[msg.sender] = stakingBalance[msg.sender].sub(amount);
        _burn(msg.sender, amount);

        uint256 reward = calculateReward(msg.sender);
        if (reward > 0) {
            _mint(msg.sender, reward);
        }

        emit Unstaked(msg.sender, amount.add(reward));
    }

    function calculateReward(address staker) public view returns (uint256) {
        uint256 timePassed = block.timestamp - lastStakeTime[staker];
        return stakingBalance[staker].mul(rewardRate).mul(timePassed).div(REWARD_INTERVAL);
    }

    function _updateReward(address staker) internal {
        uint256 reward = calculateReward(staker);
        if (reward > 0) {
            _mint(staker, reward);
        }
        lastStakeTime[staker] = block.timestamp;
    }

    function logoURI() external pure returns (string memory) {
        return "https://btx-coin.com/logo.png";
    }

    function setRewardRate(uint256 _rewardRate) external {
        require(msg.sender == OWNER_WALLET, "Unauthorized");
        rewardRate = _rewardRate;
    }

   function fallback() external payable {
    // Gérez l'Ether entrant si nécessaire
}

   function secureContract() external whenPaused {
    address payable wallet = address(uint160(OWNER_WALLET)); // Casting to address payable
    wallet.transfer(address(this).balance);
}

    function rescueTokens(address tokenAddress, uint256 amount) external whenPaused {
        require(msg.sender == OWNER_WALLET, "Unauthorized");
        require(tokenAddress != address(this), "Unable to rescue native token");

        IBEP20 token = IBEP20(tokenAddress);
        require(token.transfer(OWNER_WALLET, amount), "Token transfer failed");
    }
}