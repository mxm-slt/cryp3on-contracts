//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ISubscriptionManager.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract SubscriptionManager is Ownable, ISubscriptionManager {
    using SafeERC20 for IERC20;

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
        uint startDate;
        uint paidUntil;
    }

    Plan[] public plans;
    uint nextPlanId;

    // subscriber => (planId => Subscription)
    mapping(address => mapping(uint => Subscription)) public subscriptions;

    function createSubscriptionPlan(address token, uint payment, uint period) external override {
        require(payment > 0, "payment must be positive");
        require(period > 0, "period must be positive");
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
        Subscription storage subscription = subscriptions[subscriber][planId];
        return subscription.creator != address(0);
    }

    function isActiveSubscriber(uint planId, address subscriber) external override view returns (bool) {
        Subscription storage subscription = subscriptions[subscriber][planId];
        return subscription.paidUntil >= block.timestamp;
    }

    function getNextPayment(uint planId, address subscriber) external override view returns (uint amount, uint when) {
        Plan storage plan = plans[planId];
        Subscription storage subscription = subscriptions[subscriber][planId];
        amount = plan.payment;
        when = subscription.paidUntil;
    }

    function subscribe(uint planId) external override {
        Plan storage plan = plans[planId];
        require(plan.isActive, "Plan is inactive");

        IERC20 token = IERC20(plan.token);
        token.safeTransfer(plan.creator, plan.payment);
        emit Paid(plan.creator, planId, msg.sender, plan.payment, plan.token, block.timestamp);

        subscriptions[msg.sender][planId] = Subscription(plan.creator, block.timestamp, block.timestamp + plan.period);
        emit Subscribed(plan.creator, planId, msg.sender, block.timestamp);
    }

    function unsubscribe(uint planId) external override {
        Plan storage plan = plans[planId];
        delete subscriptions[msg.sender][planId];
        emit Unsubscribed(plan.creator, planId, msg.sender, block.timestamp);
    }

    function pay(address subscriber, uint planId) external override {
        Plan storage plan = plans[planId];
        require(plan.isActive, "Plan is inactive");

        IERC20 token = IERC20(plan.token);
        token.safeTransferFrom(subscriber, plan.creator, plan.payment);

        Subscription storage subscription = subscriptions[subscriber][planId];
        subscription.paidUntil = subscription.paidUntil + plan.period;
        emit Paid(plan.creator, planId, subscriber, plan.payment, plan.token, block.timestamp);
    }

    function withdrawFee(address token, uint amount) external {
        // fee is yet to be introduced
    }

}