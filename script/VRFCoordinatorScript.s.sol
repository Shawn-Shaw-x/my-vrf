// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../src/VRFCoodinatorV2.sol";
import "forge-std/Script.sol";
import {MyVRFConsumer} from "../src/MyVRFConsumer.sol";

contract DeployVRFCoordinatorScript is Script {
    function run() external {
        vm.startBroadcast();

        // 部署 VRFCoordinatorV2
        VRFCoordinatorV2 coordinator = new VRFCoordinatorV2();
        console2.log("VRFCoordinatorV2 deployed at:", address(coordinator));

        // consumer 部署
        MyVRFConsumer consumer = new MyVRFConsumer(address(coordinator));
        consumer.requestRandomWords(2);

        vm.stopBroadcast();
    }
}