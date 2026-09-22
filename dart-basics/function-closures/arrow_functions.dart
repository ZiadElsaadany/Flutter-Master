// An arrow function is a shorter syntax for a function that contains a single expression.
//  => returns the result of a single expression.

// int sum(int a, int b) {
//   return a + b;
// }

// same function with arrow : 
int sum(int a, int b) => a + b;

/**
  => a + b    ---->  { return a + b; }
 *  */ 

 bool isAdult(int age) => age >= 18;
 ///Use an arrow function when the function body contains a single expression.
 void main ( ) { 
  print(isAdult(19)); // ouput is: true
  }
