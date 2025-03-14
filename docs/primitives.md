# Solidity Data Types

Solidity is a statically-typed language, meaning the type of each variable must be explicitly declared.  It offers several primitive data types, which are the fundamental building blocks for more complex types. These primitive types are categorized as value types and reference types.

## Value Types

Value types are passed by value.  When used as function arguments or in assignments, a *copy* of the value is created.  Modifying the copy does not affect the original value.

### Booleans

*   `bool`: Represents boolean values, either `true` or `false`.
    ```solidity
    bool myBool = true;
    ```

### Integers

Solidity provides both signed and unsigned integers of varying sizes.

*   `int`/`uint`: Signed and unsigned integers, respectively.  `int` and `uint` are aliases for `int256` and `uint256`.
*   Specific sizes: `int8`, `int16`, ..., `int256` and `uint8`, `uint16`, ..., `uint256`.  Using smaller sizes can save gas.
    ```solidity
    uint myUint = 123;      // 256-bit unsigned integer
    int myInt = -456;       // 256-bit signed integer
    uint8 myUint8 = 255;    // 8-bit unsigned integer
    ```
*   **Operations:**
    *   **Comparisons:** `<=`, `<`, `==`, `!=`, `>=`, `>`
    *   **Bitwise:** `&` (AND), `|` (OR), `^` (XOR), `~` (NOT)
    *   **Shifts:** `<<` (left shift), `>>` (right shift)
    *   **Arithmetic:** `+`, `-`, `*`, `/`, `%` (modulo), `**` (exponentiation)
    *   **Important Note on Exponentiation:**  Be cautious with exponentiation.  If the exponent's type is smaller than 256 bits but not smaller than the base's type, higher-order bits in the exponent might not be properly cleared, potentially leading to unexpected results.

### Fixed Point Numbers

Solidity has *limited* support for fixed-point numbers.  They are represented with a decimal point (e.g., `1.3`, `.1`).  Due to their complexity and potential for rounding errors, they are not commonly used.  Consider using integers or libraries for more precise decimal representation.

### Addresses

*   `address`: Represents a 20-byte Ethereum address.
    ```solidity
    address myAddress = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    ```
*   `address payable`: An `address` that can receive Ether.  Use this type when you intend to transfer Ether to the address.
    ```solidity
    address payable recipient = payable(0xAb8483F64d9C6d1EcF9b849Ae677dd3315835cb2);
    recipient.transfer(1 ether); // Transfers 1 ether
    ```
*   **Members:** `address` types have members like `balance` (to check the Ether balance) and `transfer()` (to send Ether).

### Fixed-size Byte Arrays

*   `bytes1`, `bytes2`, ..., `bytes32`:  Hold a sequence of bytes from 1 to 32 bytes.  These are value types.
    ```solidity
    bytes3 myBytes = 0x123456;
    ```
*   **Note:** For arbitrary-length byte sequences, use `bytes` (which is a dynamic array and a reference type).

### Enums

*   `enum`:  Creates a user-defined type with a fixed set of named values.  Useful for representing choices or states.
    ```solidity
    enum Status { Pending, Approved, Rejected }
    Status currentStatus = Status.Pending;
    ```

### User-defined Value Types

*   `type`: Allows creating an alias for an existing value type.  This can improve code readability.
    ```solidity
    type MyUint is uint256;
    MyUint myVar = 10;
    ```

### Function Types

*   `function`: Represents the type of a function.  Can be used to store functions in variables or pass them as arguments.
    ```solidity
    function(uint) external returns (uint) myFunction; // Example function type
    ```
*   **Mutability:** Function types also specify their mutability (e.g., `pure`, `view`, `nonpayable`, `payable`).

## Reference Types

Reference types are passed by reference.  They point to a location in memory or storage.  Modifying a reference type affects the original data.  Reference types require a *data location* specifier: `memory`, `storage`, or `calldata`.

### Data Location

*   `memory`: Data is stored in memory and only exists during function execution. Used for temporary variables.
*   `storage`: Data is stored permanently on the blockchain. Used for contract state variables.
*   `calldata`: Data is stored in calldata, a read-only area used for function arguments.

### Arrays

*   **Fixed-size arrays:** `type[n]`, where `type` is the element type and `n` is the fixed size.
*   **Dynamic arrays:** `type[]`.  The size can change.
*   `bytes`: A special dynamic array specifically for storing byte sequences.  Often used for raw data.
*   `string`: A special dynamic array for storing UTF-8 encoded strings.
*   **Array Slices:** Used for accessing a portion of a calldata array.

### Structs

*   `struct`: Creates a custom type that can group multiple variables of different types.
    ```solidity
    struct MyStruct {
        uint myUint;
        address myAddress;
    }
    ```

### Mappings

*   `mapping(keyType => valueType)`:  Represents a key-value store (hash table).  Mappings cannot be iterated directly.
    ```solidity
    mapping(address => uint) balances;
    ```

## Literals

*   **Address literals:** Hexadecimal values that pass the address checksum test (e.g., `0x...`).
*   **Integer literals:** Decimal numbers (e.g., `10`, `123`).
*   **String literals:** Text enclosed in double or single quotes (e.g., `"hello"`, `'world'`).
*   **Unicode literals:** String literals prefixed with `unicode"` (e.g., `unicode"你好世界"`).
*   **Hexadecimal literals:** Values prefixed with `0x` (e.g., `0x123abc`).

## Operators

*   **Arithmetic:** `+`, `-`, `*`, `/`, `%`, `**`
*   **Comparison:** `==`, `!=`, `<`, `>`, `<=`, `>=`
*   **Logical:** `&&` (AND), `||` (OR), `!` (NOT)
*   **Bitwise:** `&`, `|`, `^`, `~`, `<<`, `>>`
*   **Assignment:** `=`, `+=`, `-=`, `*=`, `/=`, `%=`, `&=`, `|=`, `^=`, `<<=`, `>>=`
*   **Ternary:** `condition ? value_if_true : value_if_false`
*   **delete:** Resets a variable to its default value.

## Conversions

*   **Implicit:** The compiler automatically converts between compatible types without loss of information (e.g., `uint8` to `uint256`).
*   **Explicit:** Requires a cast using the target type (e.g., `uint8(myInt)`).  Be careful with explicit conversions as they can lead to data loss.
