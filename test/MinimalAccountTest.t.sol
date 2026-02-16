//SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {MinimalAccount} from "../src/ethereum/MinimalAccount.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {DeployAccount} from "../script/DeployAccount.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract MinimalAccountTest is Test {
    MinimalAccount minimalAccount;
    HelperConfig helperConfig;
    DeployAccount deployAccount;
    ERC20Mock public usdc;
    uint256 public constant AMOUNT = 1e18;
    address randomUser =makeAddr("randomUser");

    function setUp() public {
        deployAccount = new DeployAccount();
        (helperConfig, minimalAccount) = deployAccount.deployMinimalAccount();
        usdc = new ERC20Mock();
    }

    function testCanOwnerExecuteCommands() public {
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);

        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);

        vm.prank(minimalAccount.owner());
        minimalAccount.execute(dest, value, functionData);
        assertEq(usdc.balanceOf(address(minimalAccount)), AMOUNT);
    }

    function testNotOwnerExecuteCommands() public {
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);

        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);

        vm.prank(randomUser);
        vm.expectRevert(MinimalAccount.MinimalAccount__NotFromEntryPointOrOwner.selector);
        minimalAccount.execute(dest, value, functionData);
    }
}
