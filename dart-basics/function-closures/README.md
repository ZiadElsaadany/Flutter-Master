# Functions

## 1. Functions Are Objects and First-Class Values

### Definition

> A Dart function is an object that can be used as a value.

```dart
int sum(int first, int second) {
  return first + second;
}

void main() {
  print(sum is Function); // true
}
```

### Mental model

A function is both executable code and a value that the program can work with.
This is what **first-class value** means.

### Quick revision

Functions are objects, so Dart can treat behavior as a value.

## 2. Function Reference vs Function Invocation

### Definition

> `sum` refers to the function; `sum(...)` executes it and returns its result.

```dart
int sum(int first, int second) => first + second;

void main() {
  sum;       // Function reference: nothing runs.
  sum(2, 3); // Function invocation: runs and returns 5.
}
```

`sum()` means “invoke `sum` with no arguments.” Because this `sum` requires two
arguments, it must be invoked as `sum(2, 3)`.

### Mental model

- No parentheses: refer to the behavior.
- Parentheses: run the behavior now.

### Common mistake

Calling a function when an API expects the function itself:

```dart
sum(2, 3); // An int result, not a function reference.
```

### Quick revision

`functionName` refers to the function; `functionName()` invokes the function and evaluates to its returned value.

## 3. Storing Functions in Variables

### Definition

> A variable can store a reference to a function and invoke it later.

```dart
int sum(int first, int second) => first + second;

void main() {
  final operation = sum;
  print(operation(4, 2)); // 6
}
```

### Mental model

`operation` now points to the same behavior as `sum`. Calling `operation(...)`
runs that behavior.

### Common mistake

```dart
final operation = sum;       // Stores the function.
final result = sum(1, 2);    // Stores the returned int.
```

### Quick revision

Store a function without parentheses; use parentheses when you want to run it.

## 4. Function Types

### Definition

> A function type describes the function's return type and parameter types.

Read a function type as:

```text
ReturnType Function(ParameterType1, ParameterType2, ...)
```

Examples:

```dart
int sum(int first, int second) => first + second;
bool isAdult(int age) => age >= 18;

void main() {
  int Function(int, int) operation = sum;
  bool Function(int) ageCheck = isAdult;

  print(operation(2, 3)); // 5
  print(ageCheck(18));    // true
}
```

- `int Function(int, int)` takes two `int` values and returns an `int`.
- `bool Function(int)` takes one `int` and returns a `bool`.

### Mental model

Types inside `Function(...)` are the inputs. The type before `Function` is the
output.

### Common mistake

Avoid the broad `Function` type when the exact signature is known:

```dart
Function operation = sum;                // Weak type information.
int Function(int, int) operation = sum;  // Preferred.
```

### Quick revision

Read `bool Function(int)` as “`int` in, `bool` out.”

## 5. Passing Functions as Arguments

### Definition

> A function can receive another function through one of its parameters.

```dart
int sum(int first, int second) => first + second;

int calculate(
  int first,
  int second,
  int Function(int, int) operation,
) {
  return operation(first, second);
}

void main() {
  print(calculate(6, 3, sum)); // 9
}
```

### Mental model

`calculate` receives `sum` as a value, then decides where to invoke it.

### Common mistake

```dart
calculate(6, 3, sum);       // Correct: passes a function.
calculate(6, 3, sum(6, 3)); // Wrong: passes an int result.
```

### Quick revision

A function parameter lets the caller supply part of the receiving function's
behavior.

## 6. Passing Behavior, Not Only Data

### Definition

> Passing a function means passing an action or rule, not only a data value.

```dart
int addTax(int price) => price + 20;
int applyDiscount(int price) => price - 20;

int updatePrice(int price, int Function(int) rule) {
  return rule(price);
}

void main() {
  print(updatePrice(100, addTax));        // 120
  print(updatePrice(100, applyDiscount)); // 80
}
```

### Mental model

The data stays the same (`100`), but the function argument changes what the
program does with it.

### Quick revision

Data answers “with what?” A function argument answers “do what?”

## 7. Callbacks

### Definition

> A callback is a function passed to another function for later execution.

```dart
void handleClick() {
  print('Button clicked');
}

void runTask(void Function() callback) {
  print('Task started');
  callback(); // runTask chooses when to execute it.
}

void main() {
  runTask(handleClick);
}
```

“Later” means when the receiving function chooses. A callback can run during the
same synchronous call or after a future event; it is not automatically
asynchronous.

### Mental model

The caller provides the behavior. The receiving function controls **when** that
behavior runs.

### Common mistake

```dart
runTask(handleClick);   // Correct: passes the callback.
runTask(handleClick()); // Wrong: executes it immediately and passes void.
```

### Quick revision

A callback is passed now and called when the receiver decides.

## 8. Flutter Callback Example

### Definition

> Flutter event properties receive callbacks that Flutter invokes when events occur.

```dart
void handleClick() {
  print('Button clicked');
}

ElevatedButton(
  onPressed: handleClick,
  child: const Text('Click me'),
);
```

### Mental model

`onPressed: handleClick` gives Flutter the behavior. Flutter keeps that function
and invokes it when the user presses the button.

### Common mistake

```dart
onPressed: handleClick,   // Correct: Flutter calls it after a press.
onPressed: handleClick(), // Wrong: calls it while building the widget.
```

`handleClick()` runs immediately and returns `void`, but `onPressed` expects a
function with the type `void Function()?`.

### Quick revision

Pass `handleClick` because Flutter decides when the click has happened and when
the callback should run.

## 9. Anonymous Functions

### Definition

> An anonymous function is a function without a declared name.

```dart
var multiply = (int first, int second) {
  return first * second;
};

void main() {
  print(multiply(3, 4)); // 12
}
```

`multiply` is not the declared name of the function. It is a variable that holds
a reference to the anonymous function.

```dart
// multiply is a variable holding an anonymous function.
```

The anonymous function itself is:

```dart
(int first, int second) {
  return first * second;
}
```

Assigning that function to `multiply` does not give the function a declared
name.

### Anonymous Function as a Callback

```dart
final numbers = [1, 2, 3];

numbers.forEach((number) {
  print(number);
});
```

The function passed to `forEach` is:

```dart
(number) {
  print(number);
}
```

It is both:

- An anonymous function because it has no declared name.
- A callback because it is passed to `forEach` for `forEach` to invoke.

```dart
// An anonymous function can be passed directly as a callback.
```

### Important Distinction

```dart
// A callback describes how a function is used.
// An anonymous function describes whether the function has a name.
```

Named callback:

```dart
void printNumber(int number) {
  print(number);
}

numbers.forEach(printNumber);
```

Anonymous callback:

```dart
numbers.forEach((number) {
  print(number);
});
```

- `printNumber` is a named function used as a callback.
- `(number) { ... }` is an anonymous function used as a callback.
- Being anonymous and being a callback are two different properties.

### Mental Model

Anonymous answers:

> "Does this function have a declared name?"

Callback answers:

> "How is this function being used?"

### Quick Revision

- An anonymous function has no declared name.
- It can be stored in a variable.
- It can be passed directly as a callback.
- A variable holding an anonymous function does not turn it into a named
  function.

## 10. Arrow Functions

### Definition

> An arrow function is a shorter syntax for a function that contains a single expression.

```dart
int sum(int a, int b) => a + b;
```

It is equivalent to:

```dart
int sum(int a, int b) {
  return a + b;
}
```

```dart
// An arrow function evaluates a single expression and returns its result.
```

### Expression vs Statement

```dart
// An expression produces a value.
```

Examples of expressions:

```dart
2 + 3
age >= 18
'Hello $name'
sum(2, 3)
print('Hello')
```

A function call is an expression. This includes a call such as `print('Hello')`,
whose return type is `void`.

```dart
// A statement performs an action or controls program flow.
```

Examples of statements:

```dart
return value;

if (condition) {
}

for (final item in items) {
}

int value = 10;
```

A statement can contain an expression:

```dart
return a + b;
```

Here:

- `return a + b;` is a statement.
- `a + b` is an expression.

### Anonymous Arrow Function

```dart
var multiply = (int a, int b) => a * b;
```

```dart
// This is an anonymous arrow function stored in a variable.
```

It is:

- Anonymous because it has no declared name.
- Arrow because it uses `=>`.

### Arrow Function as a Callback

```dart
numbers.map((number) => number * 2);
```

The function passed to `map` is:

```dart
(number) => number * 2
```

It is:

- An anonymous function.
- An arrow function.
- A callback.

```dart
// This is an anonymous arrow function used as a callback.
```

### Rule

```dart
// Use an arrow function when the function body contains a single expression.
```

Do not put statements or a block after `=>`.

### Quick Revision

- `=> expression` is shorthand for `{ return expression; }`.
- An expression produces a value; a statement performs an action or controls
  flow.
- Arrow syntax works with named and anonymous functions.
- An anonymous arrow function can be passed directly as a callback.

## 11. Functions Returning Functions

### Definition

> A function can return another function as its result.

```dart
// This function returns another function.
void Function() getOperation() {
  return () {
    print('Hello');
  };
}
```

Calling:

```dart
var operation = getOperation();
```

executes `getOperation`, which returns another function. `operation` stores that
returned function, so:

```dart
operation();
```

invokes the returned function and prints `Hello`.

### Function Return Type

Read:

```dart
void Function() getOperation()
```

as:

> `getOperation` is a function that returns a function of type `void Function()`.

The first `()` belongs to the returned function type. The final `()` belongs to
the parameter list of `getOperation`.

Prefer an exact function type over the broad `Function` type when possible:

```dart
void Function() getOperation() // Exact return type.
Function getOperation()        // Broad return type.
```

### Returning Customized Behavior

```dart
int Function(int) createMultiplier(int multiplier) {
  return (int number) {
    return number * multiplier;
  };
}

void main() {
  final multiplyBy2 = createMultiplier(2);
  final multiplyBy10 = createMultiplier(10);

  print(multiplyBy2(5));  // 10
  print(multiplyBy10(5)); // 50
}
```

```dart
// A function can create and return customized behavior.
```

This line:

```dart
final multiplyBy2 = createMultiplier(2);
```

makes `multiplyBy2` have the inferred type:

```dart
int Function(int)
```

It stores the function returned by `createMultiplier`. Passing a different
`multiplier` creates behavior customized with a different value.

### Another Example

```dart
// createAdder returns a customized function based on the provided amount.
int Function(int) createAdder(int amount) {
  return (int number) {
    return number + amount;
  };
}

void main() {
  // addFive stores a function that takes an int and returns an int.
  final addFive = createAdder(5);

  print(addFive(10)); // 15
}
```

### Mental Model

A function can return behavior just like it can return data.

```text
createAdder(5)
      ↓
returns a function
      ↓
addFive stores that function
      ↓
addFive(10)
      ↓
15
```

### Quick Revision

- Functions are values, so they can be returned from other functions.
- The returned function can be stored in a variable and invoked later.
- Use an exact return type such as `int Function(int)` when possible.
- Returning functions lets us create customized behavior.

## 12. Lexical Scope

### Definition

> Lexical scope means a function can access variables from the scope where it was defined.

```dart
void main() {
  String name = 'Ziad';

  void greet() {
    print('Hello $name');
  }

  greet();
}
```

`greet` can access `name` because `greet` was defined inside the scope where
`name` exists.

```dart
// A scope defines where a variable can be accessed in the code.
```

### Inner and Outer Scopes

```dart
void main() {
  int x = 10;

  void test() {
    print(x); // ✅
  }

  test();
}
```

```dart
// An inner scope can access variables from its outer scope.
```

The reverse does not work:

```dart
void main() {
  void test() {
    int x = 10;
  }

  print(x); // ❌
}
```

This example does not compile because `x` exists only inside `test`.

```dart
// An outer scope cannot access variables declared only inside an inner scope.
```

### Where a Function Is Defined Matters

```dart
void main() {
  String name = 'Ziad';

  void greet() {
    print(name);
  }

  execute(greet);
}

void execute(void Function() callback) {
  String name = 'Ahmed';

  callback();
}
```

This prints:

```text
Ziad
```

It does not print `Ahmed`. `greet` resolves `name` from where `greet` was
defined, not from inside `execute`, where it is called.

```dart
// Lexical scope is determined by where a function is defined, not where it is called.
```

```dart
// A function looks outward from where it was defined to resolve variables.
```

### Shadowing

```dart
String name = 'Global';

void main() {
  String name = 'Ziad';

  print(name); // Ziad
}
```

```dart
// Shadowing happens when an inner scope declares a variable with the same name as an outer variable.
```

The inner `name` hides the global `name` while code is inside `main`.

```dart
void main() {
  int number = 10;

  void first() {
    int number = 20;

    void second() {
      print(number);
    }

    second();
  }

  first();
}
```

This prints `20` because Dart resolves the nearest enclosing variable first.

```dart
// Dart resolves variables from the nearest enclosing lexical scope.
```

### Mental Model

```text
A function resolves variables by looking at:
1. Its own scope
2. The nearest enclosing scope
3. The next outer scope
4. And so on
```

### Quick Revision

- Scope determines where variables can be accessed.
- Inner scopes can access outer-scope variables.
- Outer scopes cannot access variables declared only inside inner scopes.
- Lexical scope depends on where a function is defined, not where it is called.
- If multiple variables have the same name, Dart uses the nearest enclosing one.

## 13. Closures

### Definition

> A closure is a function that captures variables from its surrounding lexical scope.

```dart
// Closure = Function + Captured Outer State
```

More precisely:

```dart
// A closure is a function together with the outer variables it captures.
```

### What Exactly Is the Closure?

```dart
int Function() createCounter() {
  int count = 0;

  return () {
    count++;
    return count;
  };
}
```

The closure is the returned function itself:

```dart
() {
  count++;
  return count;
}
```

It is a closure because it captures `count` from the surrounding scope.

```dart
final counter = createCounter();
```

`counter` is a variable that holds a reference to the closure.

```text
counter
   ↓
references
   ↓
Closure
├── Function code
└── Captured environment
    └── count
```

### Capturing Variables

```dart
void main() {
  int count = 0;

  void increment() {
    count++;
    print(count);
  }

  increment(); // 1
  increment(); // 2
}
```

```dart
// increment is a closure because it captures count from its surrounding scope.
```

The function uses the surrounding `count` variable rather than receiving it as
a parameter or declaring it locally.

### Keeping Captured State Alive

```dart
int Function() createCounter() {
  int count = 0;

  return () {
    count++;
    return count;
  };
}

void main() {
  final counter = createCounter();

  print(counter()); // 1
  print(counter()); // 2
  print(counter()); // 3
}
```

```dart
// The closure keeps accessing and modifying the same captured variable across calls.
```

```dart
// A closure can keep captured variables alive even after the outer function has finished.
```

`createCounter` finishes after returning, but its captured `count` remains
available through the returned closure.

### Separate Closure State

```dart
final counter1 = createCounter();
final counter2 = createCounter();

print(counter1()); // 1
print(counter1()); // 2

print(counter2()); // 1
```

```dart
// Each closure can have its own captured state.
```

Each call to `createCounter()` creates a new closure with its own `count`.
Calling `counter1` does not change the state captured by `counter2`.

### Important Distinction

- Every closure is a function.
- The word **closure** emphasizes that the function captures variables from an
  outer lexical scope.
- A variable such as `counter` is not the closure concept itself; it stores a
  reference to the closure.

```dart
// A closure is a function that captures and retains access to variables from its lexical scope.
```

### Quick Revision

- A closure is still a function.
- It captures variables from its surrounding lexical scope.
- It can continue accessing those variables later.
- Captured variables can preserve state across multiple calls.
- Different closures can have separate captured state.
- `counter` is a variable referencing the closure; the returned function itself
  is the closure.

## 14. Higher-Order Functions

### Definition

> A higher-order function is a function that takes another function as an argument, returns a function, or both.

```dart
// A function is higher-order if it accepts a function,
// returns a function, or does both.
```

### 1. Accepting a Function

```dart
// calculate is a higher-order function because it
// accepts another function as an argument.
int calculate(
  int a,
  int b,
  int Function(int, int) operation,
) {
  return operation(a, b);
}
```

Example:

```dart
int add(int a, int b) => a + b;

void main() {
  print(calculate(5, 3, add)); // 8
}
```

### 2. Returning a Function

```dart
// createMultiplier is a higher-order function because
// it returns another function.
int Function(int) createMultiplier(int multiplier) {
  return (int number) {
    return number * multiplier;
  };
}
```

Example:

```dart
final multiplyBy2 = createMultiplier(2);

print(multiplyBy2(5)); // 10
```

### 3. Accepting and Returning a Function

```dart
// applyTwice is a higher-order function because it
// accepts a function and returns another function.
int Function(int) applyTwice(
  int Function(int) operation,
) {
  return (int number) {
    return operation(operation(number));
  };
}
```

Example:

```dart
int doubleNumber(int number) => number * 2;

void main() {
  final doubleTwice = applyTwice(doubleNumber);

  print(doubleTwice(5)); // 20
}
```

### Important Distinction

The function passed into a higher-order function is not necessarily a
higher-order function itself.

```dart
int doubleNumber(int number) => number * 2;
```

`doubleNumber` is a normal function.

```dart
int Function(int) applyTwice(
  int Function(int) operation,
) {
  return (number) => operation(operation(number));
}
```

`applyTwice` is a higher-order function because it works with another function
as a value.

### Dart Examples

Methods such as:

```dart
numbers.forEach(...)
numbers.map(...)
numbers.where(...)
```

are higher-order functions because they accept functions as arguments.

```dart
// forEach, map, and where are higher-order functions
// because they accept functions as arguments.
```

### Mental Model

```text
Normal Function
    ↓
Works mainly with data

Higher-Order Function
    ↓
Works with functions as values
```

A function can be treated like other values such as:

```dart
int
String
bool
```

Therefore, a higher-order function can receive or return behavior, not only
data.

```dart
// Higher-order functions allow behavior to be passed
// around and composed like other values.
```

### Quick Revision

- A higher-order function accepts a function, returns a function, or both.
- A callback is often passed into a higher-order function.
- Functions such as `map`, `where`, and `forEach` are common higher-order
  functions in Dart.
- The function being passed is not automatically a higher-order function.
- Higher-order functions are possible because functions are first-class values
  in Dart.

## 15. Function Parameters

### Parameters vs Arguments

```dart
// Parameters are variables declared by a function to receive values.
// Arguments are the actual values passed when calling a function.
```

```dart
void greet(String name) {
  print('Hello $name');
}

greet('Ziad');
```

`name` is a parameter; `'Ziad'` is the argument supplied for it.

```dart
// Parameters receive values.
// Arguments provide values.
```

### 1. Required Positional Parameters

```dart
// Required positional parameters are mandatory and matched by position.
```

```dart
void createUser(String name, int age) {
  print('$name - $age');
}

createUser('Ziad', 24);
```

Both arguments must be provided, and their order matters.

```dart
// Positional arguments are matched to parameters based on their order.
```

### 2. Optional Positional Parameters

```dart
// Optional positional parameters may be omitted,
// but their position still matters.
```

Place optional positional parameters inside `[]`:

```dart
void register(
  String email,
  [String? referralCode],
) {}

register('ziad@example.com');
register('ziad@example.com', 'ABC123');
```

```dart
// [] defines optional positional parameters.
```

`referralCode` is nullable because omitting it gives it the value `null`.

### 3. Optional Positional Parameters with Default Values

```dart
// A default value is used when an optional parameter is not provided.
```

```dart
void greet(String name, [int age = 18]) {
  print('$name - $age');
}

greet('Ziad');     // age = 18
greet('Ziad', 24); // age = 24
```

```dart
// A provided argument overrides the parameter's default value.
```

### 4. Named Parameters

```dart
// Named parameters are passed using their parameter names instead of their position.
```

```dart
void createUser({
  String? name,
  int? age,
}) {}

createUser(name: 'Ziad', age: 24);
createUser(age: 24, name: 'Ziad'); // Also valid.
```

```dart
// Named arguments explicitly specify which parameter receives each value.
// The order of named arguments does not matter.
// Named parameters are optional by default unless marked as required.
// {} defines named parameters.
```

```text
[] -> Optional positional parameters
{} -> Named parameters
```

### 5. Required Named Parameters

```dart
// A required named parameter must be provided by name when the function is called.
```

```dart
void createUser({
  required String name,
  required int age,
}) {}

createUser(name: 'Ziad', age: 24);
```

```dart
// required makes a named parameter mandatory without making it positional.
// required controls whether an argument must be provided.
// ? controls whether the value itself can be null.
```

These rules are independent:

```dart
void test({required String? name}) {}

test(name: null); // Valid: the argument is present and null is allowed.
```

### 6. Optional Named Parameters with Default Values

```dart
// A default value is used when an optional named parameter is not provided.
```

```dart
void createUser({
  String name = 'Guest',
  int age = 18,
}) {}
```

A non-null default avoids `?`: when the argument is omitted, the parameter
receives its default instead of `null`.

```dart
// An optional parameter needs either a nullable type or a default value.
```

### 7. Mixing Positional and Named Parameters

```dart
// A function can combine positional parameters with named parameters.
```

```dart
void createUser(
  String id, {
  required String name,
  int age = 18,
}) {
  print('$id - $name - $age');
}

createUser('user_1', name: 'Ziad', age: 24);
```

`id` is required and positional. `name` is required and named. `age` is named,
optional, and defaults to `18`.

```dart
// Positional arguments are passed by order.
// Named arguments are passed by parameter name.
// Function parameter rules also apply to constructor parameters.
```

Flutter widget constructors use the same rules:

```dart
class ProfileCard extends StatelessWidget {
  const ProfileCard(this.id, {super.key, required this.name, this.age = 18});

  final String id;
  final String name;
  final int age;

  @override
  Widget build(BuildContext context) => Text('$id - $name - $age');
}

ProfileCard('user_1', name: 'Ziad');
```

### Quick Revision

```text
String name
-> Required positional

[String? name]
-> Optional positional

[String name = 'Guest']
-> Optional positional with default value

{String? name}
-> Optional named

{required String name}
-> Required named

{String name = 'Guest'}
-> Optional named with default value
```

```dart
// Required = must be provided.
// Positional = matched by order.
// Named = matched by parameter name.
// Optional = may be omitted.
```

## 16. typedef and Function Type Aliases

### Definition

```dart
// A typedef gives a function type a readable alias.
// A typedef creates a type alias; it does not create a function or a value.
```

```dart
typedef Operation = int Function(int, int);
```

`int Function(int, int)` is the original type: two `int` inputs and an `int`
result. `Operation` is a readable alias for that same type.

```text
Operation = int Function(int, int)
```

### Why Use typedef?

Without an alias:

```dart
int calculate(
  int a,
  int b,
  int Function(int, int) operation,
) {
  return operation(a, b);
}
```

With an alias:

```dart
typedef Operation = int Function(int, int);

int calculate(
  int a,
  int b,
  Operation operation,
) {
  return operation(a, b);
}
```

```dart
// Typedefs improve readability and avoid repeating complex type declarations.
```

### Assigning Functions to a Typedef Type

```dart
typedef Operation = int Function(int, int);

int add(int a, int b) => a + b;
int subtract(int a, int b) => a - b;

void main() {
  Operation operation = add;
  print(operation(10, 5)); // 15

  operation = subtract;
  print(operation(10, 5)); // 5
}
```

Both functions have the compatible type `int Function(int, int)`, so either
can be stored in an `Operation` variable.

```dart
// A function can be assigned to a typedef variable when its function type matches the alias.
```

### Function Type Matching

```dart
typedef Validator = bool Function(String);

bool isEmailValid(String email) {
  return email.contains('@');
}

int getLength(String text) {
  return text.length;
}

Validator validator = isEmailValid; // Valid.
// Validator validator = getLength; // Invalid: returns int, not bool.
```

`getLength` accepts a `String` but returns `int`, so it cannot be assigned to
`Validator`.

```dart
// A typedef matches functions by their function type signature.
```

### Typedefs for Callbacks

```dart
typedef OnSuccess = void Function(String message);

void performTask(OnSuccess onSuccess) {
  onSuccess('Done');
}
```

Without the alias:

```dart
void performTask(
  void Function(String message) onSuccess,
) {
  onSuccess('Done');
}
```

```dart
// Typedefs make callback types easier to read and reuse.
```

### Important Distinction

- `typedef` creates an alias for a type. It creates neither a function nor a
  variable.
- A function can be assigned to a variable of that alias type when its
  signature is compatible.

### Quick Revision

```dart
// typedef = a readable alias for a type.
```

```text
typedef Operation = int Function(int, int);

Operation
    ↓
means
    ↓
int Function(int, int)
```
