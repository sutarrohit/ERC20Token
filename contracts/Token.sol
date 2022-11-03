//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

abstract contract ERC20Token {
    /**Functions */
    function name() public view virtual returns (string memory);

    function symbol() public view virtual returns (string memory);

    function decimals() public view virtual returns (uint256);

    function totalSupply() public view virtual returns (uint256);

    function balanceOf(address _owner) public view virtual returns (uint256 balance);

    function transfer(address _to, uint256 _value) public virtual returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public virtual returns (bool success);

    function approve(address _spender, uint256 _value) public virtual returns (bool success);

    function allowance(address _owner, address _spender)
        public
        view
        virtual
        returns (uint256 remaining);

    /**Events*/
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/**This contract manage owner of the contract*/
contract owned {
    // /**Events */
    event ownerChanged(address indexed oldOwner, address indexed owner);
    address private owner;

    /**Constructor */
    constructor() {
        owner = msg.sender;
        emit ownerChanged(address(0), owner);
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner can call this function");
        _;
    }

    /**
     * @dev owner of the contract transfer onwership to new owner
     * @param _newOwner Address of the new owner
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        owner = _newOwner;
        emit ownerChanged(msg.sender, _newOwner);
    }

    /**
     * @dev Return current owner of the contract
     */
    function getOwner() public view returns (address) {
        return owner;
    }
}

/**ERC20 Toekn implementation*/
contract Token is owned, ERC20Token {
    /** State Variables*/
    string private _name;
    string private _symbol;
    uint256 private _decimal;
    uint256 private _totalSupply;
    address private _minter;
    uint256 test;

    /**Mappings*/
    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;

    /** Constructor*/
    constructor() {
        _name = "Flat";
        _symbol = "FT";
        _decimal = 0;
        _totalSupply = 1000000;
        _minter = msg.sender;
        _balance[_minter] = _totalSupply;
    }

    /**
     * @dev Returns the token name.
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token symbol
     */

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the tokens decimal
     */

    function decimals() public view override returns (uint256) {
        return _decimal;
    }

    /**
     * @dev Returns the tokens in totalSupply.
     */

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the tokens balance.
     */

    function balanceOf(address _owner) public view override returns (uint256 balance) {
        return _balance[_owner];
    }

    /**
     * @dev Returns allowance of token to spender
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev Transfer token from one address to other token
     * @param _from Address of spender
     * @param _to Address of receiver
     * @param _value Number of tokens
     */
    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool success) {
        require(_from != address(0), "Address not Found");
        require(_to != address(0), "Address not Found");
        require(_balance[_from] >= _value, "You don't have enough balance");
        _balance[_from] -= _value;
        _balance[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Owner transfer token from their address to receiver
     * @param _to Address of receiver
     * @param _value Number of tokens
     */
    function transfer(address _to, uint256 _value) public override returns (bool success) {
        address owner = msg.sender;
        _transfer(owner, _to, _value);
        return true;
    }

    /**
     * @dev Spender transfer token which owner allowed them
     * @param _from Address of spender
     * @param _to Address of receiver
     * @param _value Number of tokens
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool success) {
        address spender = msg.sender;
        _spenderAllowance(_from, spender, _value);
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Owner call this function allow spender to transfer their token
     * @param _spender Address that can transfer owner's token
     * @param _value Number of tokens
     */
    function approve(address _spender, uint256 _value) public override returns (bool success) {
        address owner = msg.sender;
        _approve(owner, _spender, _value);
        return true;
    }

    /**
     * @dev Owner of token can allow spender to transfer their token
     * @param owner Owner of the token
     * @param spender Address that can transfer owner's token
     * @param _value Number of tokens
     */
    function _approve(
        address owner,
        address spender,
        uint256 _value
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = _value;
        emit Approval(owner, spender, _value);
    }

    /**
     * @dev When spender transfer this tokens, this function remove allowance of transferred tokens
     * @param from Owner of the token
     * @param spender Address that can transfer owner's token
     * @param _value Number of tokens
     */
    function _spenderAllowance(
        address from,
        address spender,
        uint256 _value
    ) internal {
        uint256 currentAllowance = allowance(from, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= _value, "ERC20: insufficient allowance");
            unchecked {
                _approve(from, spender, currentAllowance - _value);
            }
        }
    }

    /**
     * @dev Owner increase allowance of spender to spend more tokens
     * @param spender Address that can transfer owner's token
     * @param addedValue Number of tokens
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Owner decrease allowance of spender to spend less tokens
     * @param spender Address that can transfer owner's token
     * @param removeValue Number of tokens
     */
    function decreaseAllowance(address spender, uint256 removeValue) public virtual returns (bool) {
        address owner = msg.sender;
        require(allowance(owner, spender) >= removeValue, "ERC20: decreased allowance below zero");
        _approve(owner, spender, allowance(owner, spender) - removeValue);
        return true;
    }

    /**
     * @dev Owner can mint unlimited tokens
     * @param account Address to send minted tokens
     * @param amount Number of tokens to be mint
     */
    function mint(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balance[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Only owner of the token can burn thier token
     * @param account Address that burn thier tokens
     * @param amount Number of tokens to be burn
     */
    function burn(address account, uint256 amount) public {
        require(msg.sender == account, "Only owner of the token can burn thier token");
        require(account != address(0), "ERC20: mint to the zero address");
        uint256 accountBalance = _balance[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        _totalSupply -= amount;
        _balance[account] -= amount;
        emit Transfer(account, address(0), amount);
    }
}

//Contract Address: 0xA9A2dED39807a908cDA71FE2E68d9d0abcE183e5
