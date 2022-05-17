//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ISubscriptionManager.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SubscriptionManager is Ownable, ISubscriptionManager {

    struct Plan {
        uint id;
        address creator;
        address token;
        uint payment;
        uint period;
        bool isActive;
    }

    struct Subscription {
        address creator;
        uint paymentAmount;
        uint nextPaymentDate;
    }

    Plan[] public plans;
    uint nextPlanId;

    // subscriber => (planId => Subscription)
    mapping(address => mapping(address => Subscription)) public subscriptions;

    function createSubscriptionPlan(address token, uint payment, uint period) external override {
        uint id = nextPlanId;
        plans.push(Plan(id, msg.sender, token, payment, period, true));
        nextPlanId++;
        emit SubscriptionPlanCreated(msg.sender, id, block.timestamp);
    }

    function pause(uint planId) external override {
        require(plans[planId].creator == msg.sender, "Only plan creator can modify it");
        require(plans[planId].isActive, "Plan is not active");
        plans[planId].isActive = false;
        emit PlanPaused(msg.sender, planId);
    }

    function resume(uint planId) external override {
        require(plans[planId].creator == msg.sender, "Only plan creator can modify it");
        require(plans[planId].isActive, "Plan is active");
        plans[planId].isActive = true;
        emit PlanResumed(msg.sender, planId);
    }

    function creator(uint planId) external override view returns (address) {
        return plans[planId].creator;
    }

    function token(uint planId) external override view returns (address) {
        return plans[planId].token;
    }

    function price(uint planId) external override view returns (uint) {
        return plans[planId].payment;
    }

    function period(uint planId) external override view returns (uint) {
        return plans[planId].period;
    }

    function isSubscriber(uint planId, address subscriber) external override view returns (bool) {
        return false;
    }

    function getNextPayment(uint planId, address subscriber) external override view returns (uint amount, uint when) {
        when = 0;
        amount = 0;
    }

    function subscribe(uint planId) external override {

    }

    function unsubscribe(uint planId) external override {

    }

    function collectPayment(address subscriber, uint planId) external override {

    }

    function withdrawFee(address token, uint amount) external {

    }

}