// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IHotWallet {
    function deposit(uint256 _amount) external returns(bool);
    function withdraw(address _depositor, uint256 _amount) external returns(bool);
    function withdrawRequest(address _depositor, uint256 _amount) external returns(bool);
}