// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./IHotWallet.sol";

contract HotWallet is IHotWallet, Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    // Ruel address
    address public ruel;
    // mapping of depositors
    mapping(address => uint256) public depositors;

    // Events
    event Deposit(address indexed player, uint256 amount);
    event Withdraw(address indexed player, uint256 amount);
    event WithdrawRequest(address indexed player, uint256 amount);

    constructor(address _ruel) {
        // Set the ruel address
        ruel = _ruel;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @dev set the ruel address
     * @param _ruel the ruel address
     *
     */
    function setRuelAddress(address _ruel) public onlyRole(DEFAULT_ADMIN_ROLE) {
        ruel = _ruel;
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev transfer ruel tokens from user wallet to arcade wallet
     *
     */
    function deposit(uint256 _amount)
        external
        override
        whenNotPaused
        returns (bool)
    {
        require(_amount > 0, "Amount must be greater than 0");

        // Check if the sender is a depositor
        if (depositors[msg.sender] == 0) {
            // Set the depositor
            depositors[msg.sender] = _amount;
        } else {
            // Add the amount to the existing deposit
            depositors[msg.sender] += _amount;
        }

        // Transfer the tokens from sender to contract
        IERC20(ruel).transferFrom(msg.sender, address(this), _amount);

        // Emit the deposit event so that indexer can listen and update database
        emit Deposit(msg.sender, _amount);

        return true;
    }

    /**
     * @dev request a withdraw ruel tokens from arcade wallet to user wallet
     *
     */
    function withdrawRequest(address _holder, uint256 _amount) external override returns (bool) {
        require(_amount > 0, "Amount must be greater than 0");
        require(depositors[_holder] >= _amount, "Amount must be less than or equal to the initial deposit");

        // Emit the event for the indexer to listen and update the database
        emit WithdrawRequest(_holder, _amount);

        return true;
    }

    /**
     * @dev allow users to withdraw their ruel tokens
     *
     */
    function withdraw(address _depositor, uint256 _amount)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        require(_amount > 0, "Amount must be greater than 0");

        // remove the amount from the depositors
        depositors[_depositor] -= _amount;

        // Transfer the tokens from contract to sender
        IERC20(ruel).transferFrom(address(this), _depositor, _amount);

        // Emit the withdraw event so that indexer can listen and update 
        // database, also check for fraud activities
        emit Withdraw(_depositor, _amount);

        return true;
    }
}
