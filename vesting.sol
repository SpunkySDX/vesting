// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

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
    function allowance(address owner, address spender) external view returns (uint256);

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

contract SpunkySDXTokenVesting is Ownable,ReentrancyGuard{
    string public name;

    struct VestingDetail {
        address vestOwner;
        uint256 amount;
        uint256 startTime;
        uint256 cliffDuration;
        uint256 vestingDuration;
        uint256 releasedAmount;
    }

    address[] public vestingAccounts;

    IERC20 public spunkyToken;
    mapping(address => VestingDetail[]) private _vestingDetails;

    event VestingAdded(address indexed account, uint256 amount, uint256 start, uint256 cliff, uint256 duration);
    event TokensClaimed(address indexed account, uint256 amount);
    event VestingRevoked(address indexed account);
    event TokensReleased(address indexed account, uint256 amount);
    event VestingScheduleAdded(address indexed account, uint256 amount, uint256 start, uint256 cliff, uint256 duration);


    constructor(address _spunkyToken) {
        name = "SpunkySDXTokenVesting";
        require(_spunkyToken != address(0), "Token address cannot be zero address");
        spunkyToken = IERC20(_spunkyToken);
    }

     function addVestByOwner(
        address account,
        uint256 amount,
        uint256 cliffDuration,
        uint256 vestingDuration
    ) public onlyOwner {
        spunkyToken.transfer(address(this), amount);
        addVestingSchedule(account, amount, cliffDuration, vestingDuration);
    }

     function addVestingSchedule(
        address account,
        uint256 amount,
        uint256 cliffDuration,
        uint256 vestingDuration
    ) internal {
        // i removed the nonReentrant onthis function since it internal
        require(account != address(0), "Invalid account");
        require(amount > 0, "Invalid amount");
        require(
            cliffDuration < vestingDuration,
            "Cliff duration must be less than vesting duration"
        );
        require(
            spunkyToken.balanceOf(msg.sender) >= amount,
            "Owner does not have enough balance"
        );
        VestingDetail memory newVesting = VestingDetail({
            vestOwner: msg.sender,
            amount: amount,
            startTime: block.timestamp,
            cliffDuration: cliffDuration,
            vestingDuration: vestingDuration,
            releasedAmount: 0
        });
        _vestingDetails[account].push(newVesting);
        emit VestingScheduleAdded(
            account,
            amount,
            block.timestamp,
            cliffDuration,
            vestingDuration
        );
    }

     // Function to release vested tokens
    function releaseVestedTokens(address account) public nonReentrant {
        require(account != address(0), "Invalid account");
        VestingDetail[] storage vestingDetails = _vestingDetails[account];
        for (uint256 i = 0; i < vestingDetails.length; i++) {
            VestingDetail storage vesting = vestingDetails[i];
            if (
                vesting.amount > 0 &&
                vesting.amount > vesting.releasedAmount &&
                block.timestamp >= vesting.startTime + vesting.cliffDuration
            ) {
                release(account, vesting);
            }
        }
    }

    // Internal function to release vested tokens for a specific vesting detail
    function release(address account, VestingDetail storage vesting) internal {
        require(
            block.timestamp >= vesting.startTime + vesting.cliffDuration,
            "Cliff period has not ended"
        );

        require(
            vesting.releasedAmount < vesting.amount,
            "No tokens to release"
        );

        uint256 elapsedTime = block.timestamp -
            (vesting.startTime + vesting.cliffDuration);

        // If elapsed time is greater than vesting duration, set it equal to vesting duration
        elapsedTime = (elapsedTime > vesting.vestingDuration)
            ? vesting.vestingDuration
            : elapsedTime;

        // Calculate the total vested amount till now
        uint256 totalVestedAmount = (vesting.amount * elapsedTime) /
            vesting.vestingDuration;

        // Calculate the amount that is yet to be released
        uint256 unreleasedAmount = totalVestedAmount - vesting.releasedAmount;

        require(unreleasedAmount > 0, "No tokens to release");

        // Update the released amount
        vesting.releasedAmount += unreleasedAmount;

        // Transfer the tokens
        spunkyToken.transfer(account, unreleasedAmount);
        emit TokensReleased(account, unreleasedAmount);
    }

    function getNumberOfVestingSchedules(
        address account
    ) public view returns (uint256) {
        return _vestingDetails[account].length;
    }

    function getVestingDetails(
        address account
    ) public view returns (VestingDetail[] memory) {
        return _vestingDetails[account];
    }

    function withdraw() external onlyOwner {

       uint256 amount = address(this).balance;
       payable(owner()).transfer(amount);

    }

       function withdrawToken(
        address tokenAddress,
        uint256 tokenAmount
    ) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
    
        require(
            tokenAddress != address(spunkyToken),
            "Owner cannot withdraw SSDX tokens in contract"
        );
        token.transfer(owner(), tokenAmount);
    }

}