// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {RaffleContract} from "src/Raffle.sol";
import {HelperConfigs} from "script/HelperConfigs.s.sol";

contract RaffleTest is Test {
    RaffleContract public raffle;
    HelperConfigs public helperConfig;
    uint entranceFee;
    uint interval;
    address vrfCoordinator;
    uint subscriptionId;
    uint32 callbackGasLimit;
    bytes32 keyHash;

    address public User = makeAddr("person");
    uint public constant STARTING_BALANCE = 10 ether;

    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.deployContract();
        HelperConfigs.NetworkConfigs memory configs = helperConfig.getConfigs();

        entranceFee = configs.entranceFee;
        interval = configs.interval;
        vrfCoordinator = configs.vrfCoordinator;
        subscriptionId = configs.subscriptionId;
        callbackGasLimit = configs.callbackGasLimit;
        keyHash = configs.keyHash;

        vm.deal(User, STARTING_BALANCE);
    }

    function testRaffleInitializesToOpen() external view {
        assert(raffle.getRaffleState() == RaffleContract.RaffleIsOpen.OPEN);
    }

    function testShouldRevertIfMoneyNotEnough() public {
        vm.prank(User);
        vm.expectRevert(RaffleContract.Raffle__NotEnoughCashStranger.selector);
        raffle.enterRaffle();
    }

    function testShouldIncrementTheParticipants() public {
        vm.prank(User);
        raffle.enterRaffle{value: entranceFee}();

        address participantAddress = raffle.getParticipantsFromIndex(0);

        assert(participantAddress == User);
    }

    function testEnteringRaffleEmitsEvent() public {
        vm.prank(User);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(User);

        raffle.enterRaffle{value: entranceFee}();
    }
    
    function testDontAllowPlayersToEnterWhileRaffleCalculating() public {
        vm.prank(User);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        vm.expectRevert(RaffleContract.Raffle__RaffleNotOpen.selector);
        vm.prank(User);
        raffle.enterRaffle{value: entranceFee}();
    }
}