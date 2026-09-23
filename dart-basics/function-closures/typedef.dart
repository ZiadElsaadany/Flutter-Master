///// typedef and Function Type Aliases
// A typedef gives a type another name.

// A function type alias gives a readable name to a function type.
// A typedef gives a function type a readable alias.
int calculate(
  int a,
  int b,
  // int Function(int, int) operation,
  Operation operation
  // int Function(int, int)
) {
  return operation(a, b);
}

// typedef Operation = int Function(int, int);
typedef Operation = int Function(int, int);

int sum ( int num1 ,int  num2)  
{ 
 return num1 + num2; 
} 
void main ( ) { 
int result = calculate(1, 2,  sum);
print(result);


}


