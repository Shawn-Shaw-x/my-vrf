// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../lib/forge-std/src/StdAssertions.sol";
import "../lib/forge-std/src/console2.sol";
import "../src/MyVRFConsumer.sol";
import "../src/VRFCoodinatorV2.sol";
import "forge-std/Test.sol";

// 用于测试链下 fulfillRandomWords 调用
contract OracleSimulator {
    VRFCoordinatorV2 coordinator;

    constructor(address _coordinator) {
        coordinator = VRFCoordinatorV2(_coordinator);
    }

    function fulfill(uint256 requestId, uint32 numWords ) external {
        uint256[] memory words = new uint256[](numWords);
        for (uint i = 0; i < numWords; i++) {
            words[i] = uint256(keccak256(abi.encodePacked(block.timestamp, i)));
        }
        console.logString("---------- off-chain oracle random nums-------");
        for (uint i = 0; i < numWords; i++) {
            console.logUint(words[i]);
        }
        console.logString("---------- off-chain oracle random nums-------");


    coordinator.fulfillRandomWords(requestId, words);
    }
}

contract VRFTest is Test {
    VRFCoordinatorV2 coordinator;
    MyVRFConsumer consumer;
    OracleSimulator oracle;

    address oracleAddr;

    function setUp() public {
        coordinator = new VRFCoordinatorV2();
        consumer = new MyVRFConsumer(address(coordinator));
        oracle = new OracleSimulator(address(coordinator));
        oracleAddr = address(oracle);

    }

    function testVRFIntegration() public {
        // 1.consumer 请求随机数
        consumer.requestRandomWords(
            2 // numWords
        );

        // 2.模拟链上 coodinator 获取到最新 requestId
        uint256 requestId = coordinator.requestCounter();
        (
            address requester,
            uint32 numWords,
            bool fulfilled
        ) = coordinator.requests(requestId);

        // 3.模拟链下捕捉完链上事件，生成随机数后发起 fulfill（OracleSimulator 调用）
        vm.prank(oracleAddr);
        oracle.fulfill(requestId, numWords);

        // 4.consumer 验证 fulfilled 标志
        (address requester1,
        uint32 numWords1,
        bool fulfilled1
        ) = coordinator.requests(requestId);
        console.logAddress(requester1);
        console.logUint(numWords1);
        console.logBool(fulfilled1);

    assertTrue(fulfilled1);


    }
}