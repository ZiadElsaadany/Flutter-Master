// A closure is a function that captures and retains access
// to variables from its surrounding lexical scope.
// Closure = Function + Captured Environment
void main() {
  int count = 0;

  void increment() {
    count++;
    print(count);
  }

  // increment is a closure because it captures count.
  increment(); // 1
  increment(); // 2

  final counter = createCounter();

  // counter keeps access to the same captured count.
  print(counter()); // 1
  print(counter()); // 2
  print(counter()); // 3
}

int Function() createCounter() {
  int count = 0;

  return () {
    count++;
    return count;
  };
}