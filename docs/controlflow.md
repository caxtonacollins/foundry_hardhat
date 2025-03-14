# Control Flow in Solidity
Solidity, like other programming languages, uses control flow statements to determine the order in which code is executed.  This note outlines the primary control flow mechanisms in solidity.

## Sequential Execution
By default, Solidity code executes sequentially, from top to bottom.  Statements are executed in the order they appear in the source code.
```solidity
uint256 a = 10;  // Executed first
uint256 b = 20;  // Executed second
uint256 sum = a + b; // Executed third
```

## Conditional Statements
Conditional statements allow you to execute different blocks of code based on whether a condition is true or false.

### `if` statement
The `if` statement executes a block of code only if the condition is true.

```solidity
if (x > 10) {
    // This code will execute if x is greater than 10
    doSomething();
}
```

### `if-else` statement
The `if-else` statement executes one block of code if the condition is true, and another block of code if the condition is false.

```solidity
if (x > 10) {
    // This code will execute if x is greater than 10
    doSomething();
} else {
    // This code will execute if x is less than or equal to 10
    doSomethingElse();
}
```

### `if-else if` statement
The `if-else if` statement executes one block of code if the condition is true, and another block of code if the condition is false.

```solidity
if (x > 10) {
    // This code will execute if x is greater than 10
    doSomething();
} else if (x > 5) {
    // This code will execute if x is greater than 5
    doSomethingElse();
} else {
    // This code will execute if x is less than or equal to 5
    doSomethingElse();
}
```

### Ternary Operator
The ternary operator (`condition ? value_if_true : value_if_false`) provides a shorthand way to write simple if-else statements.

```solidity
uint256 y = (x > 10) ? x * 2 : x + 1; // If x > 10, y = x * 2; otherwise, y = x + 1;

// Equivalent to:
uint256 y;
if (x > 10) {
    y = x * 2;
} else {
    y = x + 1;
}
```

## Loops
Loops allow you to repeatedly execute a block of code.

### `for` loop
The `for` loop is used when you know how many times you need to iterate.

```solidity
for (uint i = 0; i < 10; i++) {
    // This code will execute 10 times
    doSomethingWith(i);
}
```

### `while` loop
The `while` loop is used when you don't know how many times you need to iterate, and the loop continues as long as a condition is true.

```solidity
uint i = 0;
while (i < 10) {
    // This code will execute as long as i is less than 10
    doSomethingWith(i);
    i++; // Important: Increment i to avoid an infinite loop
}
```

### `do-while` loop
The `do-while` loop is used when you want to execute the block of code at least once, and then iterate as long as the condition is true.

```solidity
uint i = 0;
do {
    // This code will execute at least once
    doSomethingWith(i);
    i++; // Important: Increment i to avoid an infinite loop
} while (i < 10);
```

## Break and Continue
Break and Continue are used to control the flow of loops.

### Break
The break statement is used to exit a loop prematurely.

```solidity
for (uint i = 0; i < 10; i++) {
    if (i == 5) {
        break; // Exit the loop when i equals 5
    }
    doSomethingWith(i);
}
```

### Continue
The continue statement is used to skip the rest of the current iteration and move to the next one.

```solidity
for (uint i = 0; i < 10; i++) {
    if (i % 2 == 0) {
        continue; // Skip even numbers
    }
    doSomethingWith(i);
}
```

## Revert and Require
While not strictly control flow in the same way as the others, `revert` and `require` are crucial for error handling and control the execution flow by halting execution under certain conditions.

- `require(condition, "Error message")`:  If the `condition` evaluates to `false`, the current transaction is reverted, and the provided `"Error message"` is returned.  This is used to enforce preconditions.
```solidity
require(condition, "Error message");
```
- `revert("Error message")`:  Unconditionally reverts the current transaction and provides the "Error message".  This can be used for more complex error handling scenarios.
```solidity
revert("Error message");
```
