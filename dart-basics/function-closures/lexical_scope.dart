// // Lexical scope means a function can access variables from the scope where it was defined.
// // Lexical scope is determined by where a function is defined, not where it is called.
void main() {
  String name = 'Ziad';

  void greet() {
    print('Hello $name');
  }
  //  A scope defines where a variable can be accessed in the code.

  greet(); // output is: Hello Ziad 

}


// void test() {
//   print(name); // ❌ outer scope 
// }

// // An inner scope can access variables from its outer scope.
// void main() {

//   void test() {
//     int x = 10;
//   }

//   print(x); // ❌ because An outer scope cannot access variables declared only inside an inner scope.
// }