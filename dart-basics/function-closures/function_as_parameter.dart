int sum(int a, int b) {
  return a + b;
}
int subtract(int a, int b) {
  return a - b;
}
int multiply(int a, int b) => a * b;


void executeOperation(
  int a,
  int b,
  int Function(int, int) operation,
) {
  print(operation(a, b));
}

// _______

void run(
  int Function(int) action,
) {
  print(action(5));
}

int doubleNumber(int x) {
  return x * 2;
}
void main  ( ) {  

  executeOperation(1, 2, sum) ;  // output is : 3 
  executeOperation(4, 3, subtract) ; // output is: 1
  executeOperation(10, 5, multiply); // output is: 50



  run(doubleNumber); // output is 10


}


