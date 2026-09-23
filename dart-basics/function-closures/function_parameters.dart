// Parameters are variables declared by a function to receive values when the function is called.


// name --> parameter 
void greet(String name) {
  print('Hello $name');
}

// greet('Ziad'); --> ziad is an argument 

// A parameter is declared in the function definition.
// An argument is the actual value passed when calling the function.



// 1) Required Positional Parameters
// Required positional parameters must be provided in the correct order.
int sum(int a, int b) {
  return a + b;
}
void createUser(String name, int age) {
  print('$name is $age years old');
}

void login(String email, String password) {
  print('Logging in...');
}


// 2) Optional Positional Parameters
// Optional positional parameters do not have to be provided,
// but if they are provided, their order still matters.

void greet2(String name, [int ? age]) {


 // int?  not int
  print('Hello $name, age: $age');
}


/// 3)  Default Values 
///  A default value is used when an optional parameter is not provided.
void greet3 (String name, [int? age]) {}
void greet4(String name, [int age =50  ]) {

}


///  4) Named Parameters
    // Named parameters are optional by default unless marked as required.
    // Named parameters improve readability at the call site.
/**
 Container(
  width: 100,
  height: 200,
  padding: const EdgeInsets.all(16),
)

 */

void greet5(
   { 
    required String name , 
    int? age 
   }
) {

}

// 5) Required Named Parameters : ٍRequired 

// 6) Named Parameters with Default Values



void createUser2({
  String name = 'Guest',
  int age = 18,
}) {
  print('$name - $age');
}


/**
 * void createUser(
  String id, 
  {
  required String name,
  int age = 18,
}) {}
 */

 // revision 
 /**
  
  String name
→ Required positional

[String? name]
→ Optional positional

[String name = 'Guest']
→ Optional positional + default

{String? name}
→ Optional named

{required String name}
→ Required named

{String name = 'Guest'}
→ Optional named + default
  */


void main  ( ) {  
  // 1) Required Positional Parameters
  //  Positional
  createUser("ziad", 20); // not   createUser(20, "ziad")
  // Required  
  // createUser('Ziad'); // ❌ Missing age
  // createUser(); // ❌ Missing name and age
  login("ziadelsaadany@gmail.com", "12345");
  


  // 2) Optional Positional Parameters
  greet2("ziad" ); // Hello ziad, age: null
  greet2("ziad", 30) ;  // Hello ziad, age: 30


}




