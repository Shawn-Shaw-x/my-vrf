// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2} from "./VRFCoodinatorV2.sol";

/// @title MyVRFConsumer - 一个使用 VRF 随机数的消费者示例合约
/// @notice 通过协调器请求链上随机数，接收回调并处理结果
contract MyVRFConsumer is VRFConsumerBaseV2 {
    // --- 状态变量 ---

    /// @dev VRF协调器合约实例
    VRFCoordinatorV2 public COORDINATOR;

    // --- 事件定义 ---

    /// @notice 当 fulfillRandomWords 被调用时触发，表示已获得随机数
    event GainRandomnessEvent(
        uint256 indexed requestId,
        uint256[] indexed randomWords
    );

    // --- 构造函数 ---

    /// @param coordinator 协调器合约地址
    constructor(address coordinator)
    VRFConsumerBaseV2(coordinator)
    {
        COORDINATOR = VRFCoordinatorV2(coordinator);
    }

    // --- 外部函数 ---

    /// @notice 用户调用该函数请求链上 VRF 随机数
    /// @param numWords 请求的随机数个数
    function requestRandomWords(
        uint32 numWords
    ) external {
        COORDINATOR.requestRandomWords(numWords);
    }

    // --- 实现回调 ---

    /// @notice 协调器调用该函数传回随机数
    /// @dev VRFCoordinator 合约通过 rawFulfillRandomWords 调用该函数
    /// @param requestId 请求编号
    /// @param randomWords 返回的随机数数组
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        // 此处可添加游戏逻辑、状态保存、奖励逻辑等
        emit GainRandomnessEvent(requestId, randomWords);
    }
}