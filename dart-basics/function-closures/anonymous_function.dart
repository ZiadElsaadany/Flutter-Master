 // 1) An anonymous function is a function without a name.
//  2)  An anonymous function can be stored in a variable and called later.
void main ( )  { 
  // 1 , 2 
  //function without name -->
  /**
     () {
  print('Hello');
 };
  */
  var greet = () {
  print('Hello');
};
greet(); // ouptut is Hello 
// --------
// anonymous function with parameters
// sum here is a variable holding an anonymous function not function name
var sum = (int a, int b) {
  return a + b;
};
print(sum(1,2)) ; //output is 3
}

// in Flutter 
/**
 


 void handleClick() {
  print('Clicked');
}

ElevatedButton(
  onPressed: handleClick,
  child: const Text('Click'),
);

// OR

ElevatedButton(

// why callback ? // Because it is passed to onPressed to be executed later.
  onPressed: () { --> // An anonymous function can be passed directly as a callback.
    print('Clicked');
  },
  child: const Text('Click'),
);

 */