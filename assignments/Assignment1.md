# Counter Contract Implementation Assignment

## Objective

This assignment requires you to implement a Solidity smart contract named `Counter` that manages a simple numerical counter.  The contract should provide functionalities to increase, decrease, and reset the counter, while also emitting events to track changes.  You must also handle potential overflow and underflow issues.

## Contract Specification

The `Counter` contract must adhere to the following specifications:

### State Variables

*   `uint public count`: Stores the current value of the counter.

### Events

*   `event CountIncreased(uint amount, uint when)`: Emitted when the count is increased.  `amount` represents the new count value, and `when` represents the timestamp of the increase.
*   `event CountDecreased(uint amount, uint when)`: Emitted when the count is decreased. `amount` represents the new count value, and `when` represents the timestamp of the decrease.

### Functions

*   `function increaseByOne() public`: Increases the counter by one.  This function should prevent overflow.  Emit the `CountIncreased` event.
*   `function increaseByValue(uint _value) public`: Increases the counter by a given `_value`. This function should prevent overflow. Emit the `CountIncreased` event.
*   `function decreaseByOne() public`: Decreases the counter by one. This function should prevent underflow. Emit the `CountDecreased` event.
*   `function decreaseByValue(uint _value) public`: Decreases the counter by a given `_value`. This function should prevent underflow. Emit the `CountDecreased` event.
*   `function resetCount() public`: Resets the counter to zero. Emit the `CountDecreased` event.
*   `function getCount() public view returns (uint)`: Returns the current value of the counter.
*   `function getMaxUint256() public pure returns (uint)`: Returns the maximum value of a `uint256`.  This function *must* utilize an `unchecked` block to achieve this by underflowing a `uint256`.

### Error Handling

*   Overflow:  The `increaseByOne` and `increaseByValue` functions should revert if increasing the counter would cause an overflow (exceed `type(uint).max` or `getMaxUint256()`).  Use a `require` statement with a descriptive error message: `"cannot increase beyond max uint"`.
*   Underflow: The `decreaseByOne` and `decreaseByValue` functions should revert if decreasing the counter would cause an underflow (result in a value less than 0). Use a `require` statement with a descriptive error message: `"cannot decrease below 0"`.

### Additional Requirements

*   The contract must be written in Solidity version `^0.8.24`.
*   The contract should have a valid SPDX license identifier: `// SPDX-License-Identifier: UNLICENSED` (or another appropriate license).
*   Include comprehensive NatSpec documentation (/// comments) for all state variables, events, and functions, explaining their purpose and behavior, as shown in the provided example.

## Submission

Make a Pull Request to submit your completed `Counter.sol` file.

## Grading Criteria

*   Correct implementation of all required functions.
*   Proper handling of overflow and underflow conditions.
*   Accurate emission of events.
*   Comprehensive and clear NatSpec documentation.
*   Code quality and readability.
*   Correct use of Solidity version and license identifier.

## Example Usage (Illustrative)

```solidity
// Example usage (not part of the assignment)
Counter counter = new Counter();
counter.increaseByOne(); // count should be 1
counter.increaseByValue(5); // count should be 6
counter.decreaseByOne(); // count should be 5
counter.decreaseByValue(2); // count should be 3
counter.resetCount(); // count should be 0
uint currentCount = counter.getCount(); // currentCount should be 0
```
