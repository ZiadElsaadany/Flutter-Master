// A higher-order function is a function that takes another function as an argument,
// returns a function, or both.

// calculate is a higher-order function because it accepts a function as a parameter.
int calculate(
  int a,
  int b,
  int Function(int, int) operation,
) {
  return operation(a, b);
}


// createMultiplier is a higher-order function because it returns another function.
int Function(int) createMultiplier(int multiplier) {
  return (int number) {
    return number * multiplier;
  };
}


// applyTwice is a higher-order function because it
// accepts a function and returns another function.
int Function(int) applyTwice(
  int Function(int) operation,
) {
  return (int number) {
    return operation(operation(number));
  };
}
int doubleNumber(int number) {
  return number * 2;
}
void main() {
  final multiplyBy2 = createMultiplier(2);

  print(multiplyBy2(5)); // 10

    final doubleTwice = applyTwice(doubleNumber);
     print(doubleTwice(5)); // 20

}
/**
### Mental Model

```text
Normal Function
    ↓
Works with data

Higher-Order Function
    ↓
Works with functions as values
```

A normal function usually works with values such as:

```dart
int
String
bool
```

A higher-order function can also work with functions as values.

For example:

```dart
numbers.forEach(...)
numbers.map(...)
```

`forEach` and `map` are higher-order functions because they accept another function as an argument.

```dart
// forEach and map are higher-order functions because they accept functions as arguments.
```

### Quick Revision

```dart
// A function is higher-order if it accepts a function,
// returns a function, or does both.
```
 */