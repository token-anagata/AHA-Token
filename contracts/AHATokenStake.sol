// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);

  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `to`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address to, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `from` to `to` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external returns (bool);
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
  /**
   * @dev Returns the name of the token.
   */
  function name() external view returns (string memory);

  /**
   * @dev Returns the symbol of the token.
   */
  function symbol() external view returns (string memory);

  /**
   * @dev Returns the decimals places of the token.
   */
  function decimals() external view returns (uint8);
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
  mapping(address => uint256) private _balances;

  mapping(address => mapping(address => uint256)) private _allowances;

  uint256 private _totalSupply;

  string private _name;
  string private _symbol;

  /**
   * @dev Sets the values for {name} and {symbol}.
   *
   * The default value of {decimals} is 18. To select a different value for
   * {decimals} you should overload it.
   *
   * All two of these values are immutable: they can only be set once during
   * construction.
   */
  constructor(string memory name_, string memory symbol_) {
    _name = name_;
    _symbol = symbol_;
  }

  /**
   * @dev Returns the name of the token.
   */
  function name() public view virtual override returns (string memory) {
    return _name;
  }

  /**
   * @dev Returns the symbol of the token, usually a shorter version of the
   * name.
   */
  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

  /**
   * @dev Returns the number of decimals used to get its user representation.
   * For example, if `decimals` equals `2`, a balance of `505` tokens should
   * be displayed to a user as `5.05` (`505 / 10 ** 2`).
   *
   * Tokens usually opt for a value of 18, imitating the relationship between
   * Ether and Wei. This is the value {ERC20} uses, unless this function is
   * overridden;
   *
   * NOTE: This information is only used for _display_ purposes: it in
   * no way affects any of the arithmetic of the contract, including
   * {IERC20-balanceOf} and {IERC20-transfer}.
   */
  function decimals() public view virtual override returns (uint8) {
    return 18;
  }

  /**
   * @dev See {IERC20-totalSupply}.
   */
  function totalSupply() public view virtual override returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {IERC20-balanceOf}.
   */
  function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
  {
    return _balances[account];
  }

  /**
   * @dev See {IERC20-transfer}.
   *
   * Requirements:
   *
   * - `to` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address to, uint256 amount)
    public
    virtual
    override
    returns (bool)
  {
    address owner = _msgSender();
    _transfer(owner, to, amount);
    return true;
  }

  /**
   * @dev See {IERC20-allowance}.
   */
  function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
  {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {IERC20-approve}.
   *
   * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
   * `transferFrom`. This is semantically equivalent to an infinite approval.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount)
    public
    virtual
    override
    returns (bool)
  {
    address owner = _msgSender();
    _approve(owner, spender, amount);
    return true;
  }

  /**
   * @dev See {IERC20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {ERC20}.
   *
   * NOTE: Does not update the allowance if the current allowance
   * is the maximum `uint256`.
   *
   * Requirements:
   *
   * - `from` and `to` cannot be the zero address.
   * - `from` must have a balance of at least `amount`.
   * - the caller must have allowance for ``from``'s tokens of at least
   * `amount`.
   */
  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) public virtual override returns (bool) {
    address spender = _msgSender();
    _spendAllowance(from, spender, amount);
    _transfer(from, to, amount);
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {IERC20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
  {
    address owner = _msgSender();
    _approve(owner, spender, allowance(owner, spender) + addedValue);
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {IERC20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
  {
    address owner = _msgSender();
    uint256 currentAllowance = allowance(owner, spender);
    require(
      currentAllowance >= subtractedValue,
      'ERC20: decreased allowance below zero'
    );
    unchecked {
      _approve(owner, spender, currentAllowance - subtractedValue);
    }

    return true;
  }

  /**
   * @dev Moves `amount` of tokens from `sender` to `recipient`.
   *
   * This internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `from` cannot be the zero address.
   * - `to` cannot be the zero address.
   * - `from` must have a balance of at least `amount`.
   */
  function _transfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {
    require(from != address(0), 'ERC20: transfer from the zero address');
    require(to != address(0), 'ERC20: transfer to the zero address');

    _beforeTokenTransfer(from, to, amount);

    uint256 fromBalance = _balances[from];
    require(fromBalance >= amount, 'ERC20: transfer amount exceeds balance');
    unchecked {
      _balances[from] = fromBalance - amount;
    }
    _balances[to] += amount;

    emit Transfer(from, to, amount);

    _afterTokenTransfer(from, to, amount);
  }

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements:
   *
   * - `account` cannot be the zero address.
   */
  function _mint(address account, uint256 amount) internal virtual {
    require(account != address(0), 'ERC20: mint to the zero address');

    _beforeTokenTransfer(address(0), account, amount);

    _totalSupply += amount;
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);

    _afterTokenTransfer(address(0), account, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements:
   *
   * - `account` cannot be the zero address.
   * - `account` must have at least `amount` tokens.
   */
  function _burn(address account, uint256 amount) internal virtual {
    require(account != address(0), 'ERC20: burn from the zero address');

    _beforeTokenTransfer(account, address(0), amount);

    uint256 accountBalance = _balances[account];
    require(accountBalance >= amount, 'ERC20: burn amount exceeds balance');
    unchecked {
      _balances[account] = accountBalance - amount;
    }
    _totalSupply -= amount;

    emit Transfer(account, address(0), amount);

    _afterTokenTransfer(account, address(0), amount);
  }

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
   *
   * This internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    require(owner != address(0), 'ERC20: approve from the zero address');
    require(spender != address(0), 'ERC20: approve to the zero address');

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
   * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
   *
   * Does not update the allowance amount in case of infinite allowance.
   * Revert if not enough allowance is available.
   *
   * Might emit an {Approval} event.
   */
  function _spendAllowance(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    uint256 currentAllowance = allowance(owner, spender);
    if (currentAllowance != type(uint256).max) {
      require(currentAllowance >= amount, 'ERC20: insufficient allowance');
      unchecked {
        _approve(owner, spender, currentAllowance - amount);
      }
    }
  }

  /**
   * @dev Hook that is called before any transfer of tokens. This includes
   * minting and burning.
   *
   * Calling conditions:
   *
   * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
   * will be transferred to `to`.
   * - when `from` is zero, `amount` tokens will be minted for `to`.
   * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
   * - `from` and `to` are never both zero.
   *
   * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
   */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}

  /**
   * @dev Hook that is called after any transfer of tokens. This includes
   * minting and burning.
   *
   * Calling conditions:
   *
   * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
   * has been transferred to `to`.
   * - when `from` is zero, `amount` tokens have been minted for `to`.
   * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
   * - `from` and `to` are never both zero.
   *
   * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
   */
  function _afterTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}
}

interface StandardToken {
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  ) external;

  function transfer(address _to, uint256 _value) external;

  function approve(address _spender, uint256 _value) external;

  function allowance(address _owner, address _spender)
    external
    view
    returns (uint256);

  function balanceOf(address _owner) external returns (uint256);
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor() {
    _transferOwnership(_msgSender());
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view virtual returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(owner() == _msgSender(), 'Ownable: caller is not the owner');
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public virtual onlyOwner {
    _transferOwnership(address(0));
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Internal function without access restriction.
   */
  function _transferOwnership(address newOwner) internal virtual {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}

abstract contract HandlingTime {
  function time() public view returns (uint256) {
    return block.timestamp;
  }
}

abstract contract UintHelper {
  function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }

  function max(uint256 a, uint256 b) internal pure returns (uint256) {
    return a > b ? a : b;
  }
}

contract AHAToken is ERC20, Ownable, HandlingTime {
  uint256 private maxSupply;

  uint256 private mintPercOnDeploy;

  uint256 private constant POINT_ONE_PERCENTS = 1000;

  struct MintAllowanceCheckpoint {
    uint256 canMintAt;
    string note;
    uint256 pointOnePercent;
  }

  MintAllowanceCheckpoint[] private checkpoints;

  /**
   * Constructor will immediately define all the checkpoints on which
   * the owner can mint more tokens and how many are allowed from that
   * point. The allowed amount to mint is represented in {pointOnePercent}.
   * Each point of {pointOnePercent} is allowing 0.1% of {maxSupply} to be minted.
   * The total amount to mint from {mintPointPercent} and the sum from all {checkpoints_}
   * must be 1000 or deployment will fail.
   *
   * @param name_ name of token
   * @param symbol_ symbol of token
   * @param maxSupply_ sets the max possible supply of this token.
   * Further editing is not allowed
   * @param mintPointPercent exactly how many 0.1% percent of max supply
   * will be minted on deploy. E.g. if you want to initially mint 30% of
   * max supply, set this to 300
   * @param checkpoints_ array of checkpoints. Each checkpoint is represented with:
   * - {canMintAt} a unix timestamp which defines from when can the amount be minted;
   * - {note} string to attach to a checkpoint
   * - {pointOnePercent} point one percent of allowed mint amount. E.g. to allow to mint
   * 5% of max supply on checkpoint, set this to 50
   */
  constructor(
    string memory name_,
    string memory symbol_,
    uint256 maxSupply_,
    uint256 mintPointPercent,
    MintAllowanceCheckpoint[] memory checkpoints_
  ) ERC20(name_, symbol_) Ownable() {
    maxSupply = maxSupply_;
    mintPercOnDeploy = mintPointPercent;
    _mint(owner(), (maxSupply * mintPointPercent) / POINT_ONE_PERCENTS);
    addCheckpoints(checkpoints_);

    require(
      totalPercentToBeMinted() == POINT_ONE_PERCENTS,
      'AHAToken: Total percentage allowed to mint in checkpoints needs to be 100%'
    );
  }

  function addCheckpoint(
    uint256 canMintAt,
    string memory note,
    uint256 pointOnePercent
  ) private {
    require(
      totalPercentToBeMinted() + pointOnePercent <= POINT_ONE_PERCENTS,
      'AHAToken: total to be minted is more than 100% of max supply'
    );
    require(
      time() < canMintAt,
      'AHAToken: cannot add a checkpoint in the past'
    );
    checkpoints.push(MintAllowanceCheckpoint(canMintAt, note, pointOnePercent));
  }

  function addCheckpoints(MintAllowanceCheckpoint[] memory checkpoints_)
    private
  {
    for (uint256 i = 0; i < checkpoints_.length; i++) {
      MintAllowanceCheckpoint memory checkpoint = checkpoints_[i];
      addCheckpoint(
        checkpoint.canMintAt,
        checkpoint.note,
        checkpoint.pointOnePercent
      );
    }
  }

  function getCheckpoints()
    public
    view
    returns (MintAllowanceCheckpoint[] memory)
  {
    return checkpoints;
  }

  function totalPercentToBeMinted() private view returns (uint256) {
    uint256 total = mintPercOnDeploy;

    for (uint256 i = 0; i < checkpoints.length; i++) {
      total += checkpoints[i].pointOnePercent;
    }

    return total;
  }

  function totalAllowedToMint() private view returns (uint256) {
    uint256 pointPercents = mintPercOnDeploy;

    for (uint256 i = 0; i < checkpoints.length; i++) {
      if (time() > checkpoints[i].canMintAt)
        pointPercents += checkpoints[i].pointOnePercent;
    }

    return (maxSupply * pointPercents) / POINT_ONE_PERCENTS;
  }

  /**
   * Allows the owner to mint tokens to a given address. The owner can
   * only mint the amount allowed by all the passed checkpoints. If the owner
   * hasn't minted enough tokens to completely satisfy all checkpoint allowances,
   * they can still mint more tokens.
   *
   * The method will revert if the given amount is larger than it is currently
   * allowed to mint.
   *
   * @param to address to which the amount will be minted
   * @param amount amount of tokens to mint
   */
  function mint(address to, uint256 amount) public onlyOwner {
    uint256 canMint = totalAllowedToMint() - totalSupply();
    require(amount <= canMint, 'AHAToken: mint amount exceding allowed amount');
    _mint(to, amount);
  }
}

abstract contract ReadingTime {
  // Return current timestamp
  function time() internal view returns (uint256) {
    return block.timestamp;
  }

  function secsToHours(uint256 secs) internal pure returns (uint256) {
    return secs / (60 * 60);
  }
}

abstract contract SaleFactory is Ownable, ReadingTime {
  // Each sale has an entry in the eventCode hash table with start and end time.
  // If both saleStart and saleEnd are 0, sale is not initialized
  struct Sale {
    uint256 saleStart;
    uint256 saleEnd;
  }
  mapping(bytes32 => Sale) private _eventSale;
  bytes32[] private _allSales;

  // Modifier allowing a call if and only if there are no active sales at the moment
  modifier noActiveSale() {
    for (uint256 i; i < _allSales.length; i++) {
      require(
        !saleIsActive(_eventSale[_allSales[i]]),
        'SaleFactory: unavailable while a sale is active'
      );
    }
    _;
  }

  // Modifier allowing a call only if event by eventCode is currently active
  modifier duringSale(string memory eventCode) {
    Sale storage eventSale = getEventSale(eventCode);
    require(
      saleIsActive(eventSale),
      'SaleFactory: function can only be called during sale'
    );
    _;
    clearExpiredSales();
  }

  // Modifier allowing a call only if event by eventCode is currently inactive
  modifier outsideOfSale(string memory eventCode) {
    // We are fetching the event directly through a hash, since getEventSale reverts if sale is not initialized
    Sale storage eventSale = _eventSale[hashStr(eventCode)];
    require(
      !saleIsActive(eventSale),
      'SaleFactory: function can only be called outside of sale'
    );

    _;
  }

  function saleIsActive(Sale memory sale) private view returns (bool) {
    return (time() >= sale.saleStart) && (time() < sale.saleEnd);
  }

  // Returns all active or soon-to-be active sales in an array ordered by sale end time
  function getAllSales() public view returns (Sale[] memory) {
    uint256 length = _allSales.length;

    Sale[] memory sales = new Sale[](length);

    for (uint256 i; i < length; i++) {
      sales[i] = _eventSale[_allSales[i]];
    }
    return sales;
  }

  // Clears all sales from the _allSales array who's saleEnd time is in the past
  function clearExpiredSales() private returns (bool) {
    uint256 length = _allSales.length;
    if (length > 0 && _eventSale[_allSales[0]].saleEnd <= time()) {
      uint256 endDelete = 1;

      bytes32[] memory copyAllSales = _allSales;

      uint256 i = 1;
      while (i < length) {
        if (_eventSale[_allSales[i]].saleEnd > time()) {
          endDelete = i;
          break;
        }
        i++;
      }

      for (i = 0; i < length; i++) {
        if (i < length - endDelete) {
          _allSales[i] = copyAllSales[i + endDelete];
        } else {
          _allSales.pop();
        }
      }
    }
    return true;
  }

  function hashStr(string memory str) internal pure returns (bytes32) {
    return bytes32(keccak256(bytes(str)));
  }

  /**
   * @dev Function inserts a sale reference in the _allSales array and orders it by saleEnd time
   * in ascending order. This means the first sale in the array will expire first.
   * @param saleHash hash reference to the sale mapping structure
   */
  function insertSale(bytes32 saleHash) private returns (bool) {
    uint256 length = _allSales.length;

    bytes32 unorderedSale = saleHash;
    bytes32 tmpSale;

    for (uint256 i; i <= length; i++) {
      if (i == length) {
        _allSales.push(unorderedSale);
      } else {
        if (
          _eventSale[_allSales[i]].saleEnd > _eventSale[unorderedSale].saleEnd
        ) {
          tmpSale = _allSales[i];
          _allSales[i] = unorderedSale;
          unorderedSale = tmpSale;
        }
      }
    }
    return true;
  }

  /**
   * @dev Function returns Sale struct with saleEnd and saleStart. Function reverts if event is not initialized
   * @param eventCode string code of event
   */
  function getEventSale(string memory eventCode)
    private
    view
    returns (Sale storage)
  {
    Sale storage eventSale = _eventSale[hashStr(eventCode)];
    require(
      eventSale.saleStart > 0 || eventSale.saleEnd > 0,
      'SaleFactory: sale not initialized'
    );
    return eventSale;
  }

  function saleDuration(string memory eventCode)
    internal
    view
    returns (uint256)
  {
    (, uint256 saleStart, uint256 saleEnd) = isSaleOn(eventCode);
    return saleEnd - saleStart;
  }

  /**
   * @dev Function to set the start and end time of the next sale.
   * Can only be called if there is currently no active sale and needs to be called by the owner of the contract.
   * @param start Unix time stamp of the start of sale. Needs to be a timestamp in the future. If the start is 0, the sale will start immediately.
   * @param end Unix time stamp of the end of sale. Needs to be a timestamp after the start
   */
  function setSaleStartEnd(
    string memory eventCode,
    uint256 start,
    uint256 end
  ) public onlyOwner outsideOfSale(eventCode) returns (bool) {
    bool initialized;
    bytes32 saleHash = hashStr(eventCode);
    Sale storage eventSale = _eventSale[saleHash];
    if (eventSale.saleStart == 0 && eventSale.saleEnd == 0) {
      initialized = false;
    }

    if (start != 0) {
      require(start > time(), 'SaleFactory: given past sale start time');
    } else {
      start = time();
    }
    require(
      end > start,
      'SaleFactory: sale end time needs to be greater than start time'
    );

    eventSale.saleStart = start;
    eventSale.saleEnd = end;

    if (!initialized) {
      insertSale(saleHash);
    }

    return true;
  }

  // Function can be called by the owner during a sale to end it prematurely
  function endSaleNow(string memory eventCode)
    public
    onlyOwner
    duringSale(eventCode)
    returns (bool)
  {
    Sale storage eventSale = getEventSale(eventCode);

    eventSale.saleEnd = time();
    return true;
  }

  /**
   * @dev Public function which provides info if there is currently any active sale and when the sale status will update.
   * Value saleActive represents if sale is active at the current moment.
   * If sale has been initialized, saleStart and saleEnd will return UNIX timestampts
   * If sale has not been initialized, function will revert.
   * @param eventCode string code of event
   */
  function isSaleOn(string memory eventCode)
    public
    view
    returns (
      bool saleActive,
      uint256 saleStart,
      uint256 saleEnd
    )
  {
    Sale storage eventSale = getEventSale(eventCode);

    if (eventSale.saleStart > time()) {
      return (false, eventSale.saleStart, eventSale.saleEnd);
    } else if (eventSale.saleEnd > time()) {
      return (true, eventSale.saleStart, eventSale.saleEnd);
    } else {
      return (false, eventSale.saleStart, eventSale.saleEnd);
    }
  }
}

abstract contract RecordingTokenStakes {}

contract AHATokenStake is Ownable, SaleFactory, UintHelper {
  AHAToken private stakingToken;

  StandardToken private rewardToken;

  struct EventStakeData {
    uint256 totalStaked;
    uint256 totalReward;
    mapping(address => uint256) userStake;
    mapping(address => uint256) userStakedAt;
    mapping(address => bool) userUnstaked;
    address[] usersStaked;
  }

  mapping(bytes32 => EventStakeData) private eventStakeData;

  uint256 private constant ALLOW_UNSTAKING_AFTER_SEC = 60 * 60;

  constructor(AHAToken stakingToken_, StandardToken rewardToken_) Ownable() {
    setStakingToken(stakingToken_);
    setRewardToken(rewardToken_);
  }

  modifier userStakedLongEnough(string memory eventCode, address user) {
    (bool saleActive, , ) = isSaleOn(eventCode);
    uint256 userStakedAt = eventStakeData[hashStr(eventCode)].userStakedAt[
      user
    ];
    uint256 userStakedForSecs = userStakedFor(eventCode, user);

    require(
      (userStakedAt != 0 && userStakedForSecs >= ALLOW_UNSTAKING_AFTER_SEC) ||
        !saleActive,
      'AHATokenStake: User not staked long enough'
    );
    _;
  }

  modifier userNotUnstaked(string memory eventCode, address user) {
    bool userUnstaked = hasUserUnstaked(eventCode, user);
    require(!userUnstaked, 'AHATokenStake: User is already unstaked');
    _;
  }

  function hasUserUnstaked(string memory eventCode, address user)
    public
    view
    returns (bool)
  {
    return eventStakeData[hashStr(eventCode)].userUnstaked[user];
  }

  function userStakedFor(string memory eventCode, address user)
    private
    view
    returns (uint256)
  {
    (, , uint256 saleEnd) = isSaleOn(eventCode);
    uint256 userStakedAt = eventStakeData[hashStr(eventCode)].userStakedAt[
      user
    ];
    return min(time(), saleEnd) - userStakedAt;
  }

  function setStakingToken(AHAToken stakingToken_) public onlyOwner {
    stakingToken = stakingToken_;
  }

  function setRewardToken(StandardToken rewardToken_) public onlyOwner {
    rewardToken = rewardToken_;
  }

  /**
   * Allows owner to deposit event reward. The owner needs to pre-approve
   * the required funds on the provided StandardToken instance to be able
   * to deposit.
   *
   * NOTE: Do not deposit the reward through other contracts. This method
   * is required to be run to record the total reward for the given event
   *
   * @param eventCode to deposit the reward for
   * @param amount of reward tokens to deposit
   */
  function depositEventReward(string memory eventCode, uint256 amount)
    public
    onlyOwner
  {
    rewardToken.transferFrom(_msgSender(), address(this), amount);
    eventStakeData[hashStr(eventCode)].totalReward += amount;
  }

  function isUserStaked(string memory eventCode, address user)
    private
    view
    returns (bool)
  {
    address[] memory usersStaked = eventStakeData[hashStr(eventCode)]
      .usersStaked;

    for (uint256 i = 0; i < usersStaked.length; i++) {
      if (usersStaked[i] == user) return true;
    }

    return false;
  }

  function getEventData(string memory eventCode)
    public
    view
    returns (uint256, uint256)
  {
    EventStakeData storage data = eventStakeData[hashStr(eventCode)];
    return (data.totalReward, data.totalStaked);
  }

  /**
   * Calculates the reward for given sale and user
   *
   * @param eventCode of the sale you want to get the reward for
   * @param user to calculate the reward for
   * @return reward amount
   */
  function calculateReward(string memory eventCode, address user)
    private
    view
    returns (uint256)
  {
    EventStakeData storage stakeData = eventStakeData[hashStr(eventCode)];

    uint256 totalStakedAmount = stakeData.totalStaked;
    if (totalStakedAmount == 0) return 0;
    uint256 userStakedAmount = stakeData.userStake[user];
    uint256 userStakedForH = secsToHours(userStakedFor(eventCode, user));
    uint256 totalSaleDurationH = secsToHours(saleDuration(eventCode));
    uint256 totalReward = stakeData.totalReward;

    if (userStakedForH == 0 && totalSaleDurationH == 0) {
      userStakedForH = 1;
      totalSaleDurationH = 1;
    }

    return
      (userStakedAmount * userStakedForH * totalReward) /
      (totalStakedAmount * totalSaleDurationH);
  }

  function getCurrentUserReward(string memory eventCode, address user)
    public
    view
    returns (uint256)
  {
    uint256 userReward = calculateReward(eventCode, user);
    bool userUnstaked = hasUserUnstaked(eventCode, user);

    return userUnstaked ? 0 : userReward;
  }

  function getTotalUserReward(string memory eventCode, address user)
    public
    view
    returns (uint256)
  {
    return calculateReward(eventCode, user);
  }

  function addUserStaked(string memory eventCode, address user) private {
    EventStakeData storage stakeData = eventStakeData[hashStr(eventCode)];

    stakeData.usersStaked.push(user);
    stakeData.userStakedAt[user] = time();
  }

  function recordUserStake(
    string memory eventCode,
    address user,
    uint256 amount
  ) private {
    bytes32 eventHash = hashStr(eventCode);

    eventStakeData[eventHash].totalStaked += amount;
    eventStakeData[eventHash].userStake[user] += amount;

    if (!isUserStaked(eventCode, user)) addUserStaked(eventCode, user);
  }

  function getEventReward(string memory eventCode)
    public
    view
    returns (uint256)
  {
    return eventStakeData[hashStr(eventCode)].totalReward;
  }

  function getEventTotalStaked(string memory eventCode)
    public
    view
    returns (uint256)
  {
    return eventStakeData[hashStr(eventCode)].totalStaked;
  }

  function getUserStaked(string memory eventCode, address user)
    public
    view
    returns (uint256)
  {
    return eventStakeData[hashStr(eventCode)].userStake[user];
  }

  function recordUserUnstaked(string memory eventCode, address user) private {
    eventStakeData[hashStr(eventCode)].userUnstaked[user] = true;
  }

  /**
   * Allows users to stake while the sale is on,
   * as long as they haven't unstaked during this event.
   *
   * @param eventCode of the event to stake for
   * @param amount you wish to stake
   */
  function stake(string memory eventCode, uint256 amount)
    public
    duringSale(eventCode)
    userNotUnstaked(eventCode, _msgSender())
  {
    stakingToken.transferFrom(_msgSender(), address(this), amount);
    recordUserStake(eventCode, _msgSender(), amount);
  }

  /**
   * Allows users to unstake from an event and claim their rewards.
   * Each user can only unstake once per event and they need to be
   * staked a required amount of time before they can unstake,
   * unless they have staked less than the required waiting
   * period before the event ended.
   *
   * @param eventCode of the event to unstake from
   */
  function unstake(string memory eventCode)
    public
    userStakedLongEnough(eventCode, _msgSender())
    userNotUnstaked(eventCode, _msgSender())
  {
    uint256 userStake = getUserStaked(eventCode, _msgSender());
    uint256 reward = calculateReward(eventCode, _msgSender());

    stakingToken.transfer(_msgSender(), userStake);
    rewardToken.transfer(_msgSender(), reward);

    recordUserUnstaked(eventCode, _msgSender());
  }
}
