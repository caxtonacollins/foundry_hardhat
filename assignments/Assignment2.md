# Assignment 2: Simple Student Registry

## Objective

This assignment requires you to implement a Solidity smart contract for a Simple Student Registry.  The registry will manage student information, including their name, attendance, and interests.  You will implement core functionalities for registering students, marking attendance, and managing interests, along with more advanced features like ownership and security considerations.

## Contract Specification

The `StudentRegistry` contract must adhere to the following specifications:

### Data Structures

*   **`enum Attendance { Present, Absent }`**:  Defines the possible attendance statuses.
*   **`struct Student { string name; Attendance attendance; string[] interests; }`**: Represents a student with their name, attendance, and interests.

### State Variables

*   **`mapping(address => Student) public students`**: Maps a student's address to their `Student` struct.
*   **`address public owner`**: Stores the address of the contract owner.

### Events

*   **`event StudentCreated(address _studentAddress, string _name)`**: Emitted when a new student is registered.
*   **`event AttendanceStatus(address _studentAddress, Attendance _attendance)`**: Emitted when a student's attendance is updated.
*   **`event InterestAdded(address _studentAddress, string _interest)`**: Emitted when a student's interest is added.
*   **`event InterestRemoved(address _studentAddress, string _interest)`**: Emitted when a student's interest is removed.

### Modifiers

*   **`modifier onlyOwner()`**: Restricts access to only the contract owner.
*   **`modifier studentExists(address _address)`**: Ensures a student with the given address is registered.
*   **`modifier studentDoesNotExist(address _address)`**: Ensures a student with the given address is NOT registered.

### Functions

#### Core Functionality (Basic)

1.  **`registerStudent(string memory _name, Attendance _attendance, string[] memory _interests) public`**: Registers a new student.
    *   Populate the `Student` struct from the provided arguments.
    *   Store the student's information in the `students` mapping.
    *   Emit the `StudentCreated` event.

2.  **`registerNewStudent(string memory _name) public studentDoesNotExist(_name) `**: Registers a new student with default attendance (`Absent`).
    *   Takes the student's name as input.
    *   Stores the student's information in the mapping.
    *   **Input Validation:** Ensure the student name is not empty.
    *   **Modifier:** Use the `studentDoesNotExist` modifier.
    *   Emit the `StudentCreated` event.

3.  **`markAttendance(address _address, Attendance _attendance) public studentExists(_address)`**: Records a student's attendance.
    *   Takes the student's address and attendance status as input.
    *   Updates the student's attendance in the `students` mapping.
    *   **Input Validation:** Ensure the student is already registered using the `studentExists` modifier.
    *   Emit the `AttendanceStatus` event.

4.  **`addInterest(address _address, string memory _interest) public studentExists(_address)`**: Adds an interest to a student's profile.
    *   Takes the student's address and the interest as input.
    *   Adds the interest to the student's `interests` array.
    *   **Input Validation:** Ensure the student is registered, the interest is not empty, and the student has less than 5 interests.
    *   **Challenge:** Prevent duplicate interests from being added.
    *   Emit the `InterestAdded` event.

#### Advanced Functionality (Intermediate)

5.  **`removeInterest(address _address, string memory _interest) public studentExists(_address)`**: Removes an interest from a student's profile.
    *   Takes the student's address and the interest to remove as input.
    *   Removes the specified interest from the student's `interests` array. Consider efficient removal.
    *   **Input Validation:** Ensure the student is registered and the interest exists in their profile.

6.  **Getters:** Implement the following `public view` functions:
    *   `getStudentName(address _address) public view studentExists(_address) returns (string memory)`
    *   `getStudentAttendance(address _address) public view studentExists(_address) returns (Attendance)`
    *   `getStudentInterests(address _address) public view studentExists(_address) returns (string[] memory)`
    *   **Input Validation:** Ensure the student is registered.

#### Ownership and Security (Advanced)

7.  **`constructor()`**: Set the contract deployer as the initial owner.
8.  **`transferOwnership(address _newOwner) public onlyOwner`**: Allows the current owner to transfer ownership.
    *   **Modifier:** Use the `onlyOwner` modifier.

### Additional Requirements

*   The contract must be written in Solidity version `^0.8.24`.
*   Include comprehensive NatSpec documentation (/// comments) for all state variables, events, modifiers, and functions.
*   Think about potential security vulnerabilities (e.g., reentrancy, gas limit attacks).  While not required to implement mitigations for this assignment, understanding the risks is important.

### Bonus (Optional)

*   Implement a function to allow a student to update their own name.
*   Explore other data structures (e.g., mappings within structs) for managing student data.
*   Write unit tests for your contract.

### Submission

Make a Pull Request to submit your completed `StudentRegistry.sol` file.

### Grading Criteria

*   Correct implementation of all required functions.
*   Proper use of enums, structs, and mappings.
*   Accurate emission of events.
*   Comprehensive and clear NatSpec documentation.
*   Code quality and readability.
*   Correct use of Solidity version.
*   Proper implementation of ownership and access control using modifiers.
*   Consideration of security implications.

## Example Usage (Illustrative)

```solidity
// Example usage (not part of the assignment)
StudentRegistry registry = new StudentRegistry();
address student1 = address(0x1); // Replace with a real address in a test environment
address student2 = address(0x2);

registry.registerNewStudent("Alice"); // Alice is registered with default 'Absent' attendance
registry.markAttendance(0x1, Attendance.Present); // Alice's attendance is marked as Present

string[] memory interests = new string[](2);
interests[0] = "Coding";
interests[1] = "Reading";
registry.registerStudent("Bob", Attendance.Absent, interests); //Bob is registered with specific attendance and interests

registry.addInterest(student1, "Blockchain"); // Alice's interest is added

string memory aliceName = registry.getStudentName(student1); // Returns "Alice"
Attendance aliceAttendance = registry.getStudentAttendance(student1); // Returns Attendance.Present
string[] memory aliceInterests = registry.getStudentInterests(student1); // Returns ["Coding", "Blockchain"]

registry.removeInterest(student1, "Coding"); //remove interest from Alice
```
