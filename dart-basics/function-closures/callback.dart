
 // A callback is a function passed to another function
 // to be executed later when needed.

 // another definition : 
 // A callback is a function passed to another function for later execution.
 // 


void process(int Function(int) callback) {
  print(callback(5));

}

int doubleNumber(int x) {
  return x * 2;
}

void main() {

  process(doubleNumber); // output is : 10   doubleNumber is callback
}


void handleClick() {
  print('Clicked');
}

// ElevatedButton(
// Pass the function itself as a callback.
/**   onPressed: handleClick,  // handleClick not handleClick()  --> // Passes the handleClick function as a callback without executing it immediately. */

//   child: const Text('Click'),
// );