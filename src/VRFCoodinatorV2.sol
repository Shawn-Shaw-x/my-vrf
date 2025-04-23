// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

/// @title VRFCoordinatorV2 - 一个最简版链上 VRF 协调器合约
/// @notice 接收消费者随机数请求，抛出事件供链下预言机监听，并接收链下 fulfill 回调将随机数发给消费者
/// @dev 不包含订阅系统、权限控制、链下证明、验证等，仅为链下回调流程的最小实现示例
contract VRFCoordinatorV2 {
    // --- 数据结构 ---

    /// @dev 请求结构体，记录每一次 requestRandomWords 调用信息
    struct Request {
        address requester;    // 请求方地址（消费者）
        uint32 numWords;      // 请求的随机数个数
        bool fulfilled;       // 是否已被 fulfill 处理
    }

    /// @dev 请求记录表，按 requestId 索引
    mapping(uint256 => Request) public requests;

    /// @dev 请求 ID 计数器，自增生成唯一 ID
    uint256 public requestCounter;

    // --- 事件定义 ---

    /// @notice 当有请求发起时抛出，链下预言机监听后生成随机数
    event RandomWordsRequested(
        uint256 indexed requestId,
        address indexed requester,
        uint32 numWords
    );

    /// @notice 当 fulfill 被链下预言机调用时触发，表示随机数已交付
    event RandomWordsFulfilled(
        uint256 indexed requestId,
        uint256[] randomWords
    );

    // --- 外部函数 ---

    /// @notice 消费者合约调用以请求链上 VRF 随机数
    /// @param numWords 请求的随机数个数
    /// @return requestId 本次请求的唯一 ID
    function requestRandomWords(
        uint32 numWords
    ) external returns (uint256 requestId) {
        requestId = ++requestCounter;

        // 保存请求信息
        requests[requestId] = Request({
            requester: msg.sender,
            numWords: numWords,
            fulfilled: false
        });

        // 抛出事件供链下监听
        emit RandomWordsRequested(requestId, msg.sender, numWords);
    }

    /// @notice 被链下预言机节点调用，传入随机数并回调给消费者
    /// @dev 假设链下已完成证明校验，此处不再验证
    /// @param requestId 请求编号
    /// @param randomWords 生成的随机数数组
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) external {
        Request storage req = requests[requestId];
        require(!req.fulfilled, "Already fulfilled");

        req.fulfilled = true;

        // 回调请求方合约，将随机数传递回去
        VRFConsumerBaseV2(req.requester).rawFulfillRandomWords(
            requestId,
            randomWords
        );

        // 抛出事件供监听与确认
        emit RandomWordsFulfilled(requestId, randomWords);
    }
}