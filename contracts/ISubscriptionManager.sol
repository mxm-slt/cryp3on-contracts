pragma solidity ^0.8.0;

interface ISubscriptionManager {

    function createSubscriptionPlan(address token, uint payment, uint period) external;

    function creator(uint planId) external view returns (address);
    function token(uint planId) external view returns (address);
    function price(uint planId) external view returns (uint);
    function period(uint planId) external view returns (uint);

    function pause(uint planId) external;
    function resume(uint planId) external;

    function isSubscriber(uint planId, address subscriber) external view returns (bool);
    function getNextPayment(uint planId, address subscriber) external view returns (uint amount, uint when);

    function subscribe(uint planId) external;
    function unsubscribe(uint planId) external;
    function collectPayment(address subscriber, uint planId) external;

    event SubscriptionPlanCreated(address creator, uint planId, uint date);
    event Subscribed(address creator, uint planId, address subscriber, uint date);
    event Unsubscribed(address creator, uint planId, address subscriber, uint date);
    event Paid(address creator, uint planId, address subscriber, uint amount, uint token, uint date);

    event PlanPaused(address creator, uint planId);
    event PlanResumed(address creator, uint planId);
}
