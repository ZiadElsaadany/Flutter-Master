
void main( ) { 
    // 1: Functions 
// In Dart, a function is an object.
var  result = sum ; 
// int Function(int,int) result = sum  
// sum not sum() why ? 
// sum : Store the function itself inside result.
// sum() : Execute sum now, then store the returned value inside result.
print(result(1,2)); 


int Function(int,int) x = multiply;
print(x(1,2)); // output is 2 



String Function(String) stringFunction = greet;
print(stringFunction("Ziad")); // output :  Hello Ziad


bool Function(int) ageFunction = isAdult; 
print(ageFunction(18)); // true

} 
int sum ( int num1, int num2) { 
    return num1 + num2 ; 
}
int multiply(int num1 , int num2 ) {  
    return num1 * num2 ;
}
String greet(String name) {
  return 'Hello $name';
}
bool isAdult(int age) {
  return age >= 18;
}