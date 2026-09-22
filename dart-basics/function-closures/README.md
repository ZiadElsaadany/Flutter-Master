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
