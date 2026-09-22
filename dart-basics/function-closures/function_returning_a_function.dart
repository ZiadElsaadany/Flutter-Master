// A function can return another function as its result.

// This function returns another function.
Function getOperation() {
  return () {
    print('Hello');
  };
}
// This function returns another function.
void Function() getOperation2() {
  return () {
    print('Hello');
  };
}
 
int Function(int) createMultiplier(int multiplier) {
  return (int number) {
    return number * multiplier;
  };
}
void main( ) {  
  var x = getOperation(); // x is a function 
  x(); // output is Hello

 int Function(int) multiplyBy2 =  createMultiplier(2);
 int Function(int) multiplyBy3 = createMultiplier(3);
 var multiplyBy10 = createMultiplier(10);
 multiplyBy2(5) ; //10 
 multiplyBy3(5);  //15 
 multiplyBy10(5); // 50
 
}


