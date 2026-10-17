# Dart Language — Interview Questions

## 1. `var` vs `final` vs `const` vs `dynamic` vs `late`

### Question

> What is the difference between `final`, `const`, `var`, `dynamic` and `late`?

### Answer

- `var`: the type is **inferred** from the first value and then fixed. You can reassign
  the variable, but only with a value of the same type.
- `final`: assigned **once**. The value can be computed at **runtime** (an API result,
  `DateTime.now()`).
- `const`: a **compile-time constant**. The value must be known when compiling. It is
  deeply immutable, and identical `const` values share one instance in memory.
- `dynamic`: turns **off static type checking**. The variable can hold any type and the
  type can change, so errors show up at runtime instead of compile time.
- `late`: a non-nullable variable that is **initialized later**, after its declaration.
  If you read it before assigning it, you get a `LateInitializationError` at runtime.
  `late final x = compute();` is also **lazy**: `compute()` runs on the first read.

```dart
var name = 'Ziad';         // inferred as String
name = 'Omar';             // OK
// name = 5;               // Compile error: name is a String

final now = DateTime.now(); // runtime value, assigned once
const pi = 3.14;            // compile-time constant
// const t = DateTime.now(); // Compile error: not known at compile time

dynamic value = 'text';
value = 42;                 // OK: type checks are off
value.foo();                // Compiles, crashes at runtime

late final String token;    // assigned later, exactly once
void init() => token = 'abc';
```

### Mental model

- `var` / `final` / `const`: how many times can it change, and *when* is the value known?
- `dynamic`: "compiler, stop checking me."
- `late`: "trust me, it will have a value before anyone reads it."

### Common mistake

The candidate couldn't explain `var` (it is **type inference**). They also described
`dynamic` as "something like a list". `dynamic` has nothing to do with collections; it
means the type itself isn't checked.

Prefer `Object?` over `dynamic` when you really accept anything. `Object?` still forces
you to check the type before calling methods.

### Quick revision

`var` infers and fixes the type. `final` is runtime, assigned once. `const` is
compile-time and deeply immutable. `dynamic` means no type checks. `late` means
non-null, assigned later (and lazy when it has an initializer).

## 2. Sequential vs Parallel API Calls

### Question

> When you have several API requests, how do you decide whether they run sequentially
> or in parallel? How do you run two calls in parallel without the first waiting for
> the second?

### Answer

- Run them **sequentially** when one request **depends** on another one's result
  (for example, get `userId`, then fetch that user's orders).
- Run them **in parallel** when they are independent (for example, banners and
  categories on the home screen). The total time is then the slowest call, not the sum.
- In Dart you start both futures first and await them together, with `Future.wait`
  or, in Dart 3, the `.wait` extension on records, which keeps each result's type.

```dart
// Sequential: the second call needs the first result.
final user = await api.getUser();
final orders = await api.getOrders(user.id);

// Parallel: both requests start immediately.
final (banners, categories) = await (api.getBanners(), api.getCategories()).wait;

// Parallel with a list of futures of the same type.
final pages = await Future.wait([api.page(1), api.page(2), api.page(3)]);
```

### Mental model

`await` means "pause here until this finishes". Awaiting two calls one after the other
makes them sequential, even when they are independent.

### Common mistake

The candidate answered with the architecture ("I have Bloc, use cases, I call it in
`initState`"). That doesn't answer *how* the calls run in parallel. The answer is
`Future.wait` or record `.wait`.

Also: if one future in `Future.wait` fails, the whole wait fails. Decide whether one
failed section should break the whole screen.

### Quick revision

Dependent calls run sequentially. Independent calls run in parallel with
`Future.wait([...])` or `(a(), b()).wait`.

## 3. Does `async`/`await` Run on Another Thread?

### Question

> Does the code inside an `async`/`await` block run on another thread, or on the main
> thread with the rest of the code?

### Answer

No. It runs on the **same isolate** (the main/UI isolate). Dart runs your code on one
thread per isolate, using an **event loop**.

`await` doesn't create a thread. It **suspends** the function and gives control back
to the event loop, so other work (frames, taps) keeps running. When the future
completes, the function continues from where it paused.

Network and file I/O wait in the platform/OS, not in your Dart code, so they don't
block. **CPU-heavy** Dart work inside an `async` function still blocks the UI. For that
you need an isolate (see [Performance: Isolates](../10-performance/README.md#3-when-do-you-need-an-isolate)).

```dart
Future<void> load() async {
  final json = await http.get(url);  // waiting: UI stays responsive
  final items = parseHugeJson(json); // CPU work: UI freezes if this is slow
}
```

### Mental model

`async` is about **waiting** without blocking. It is not about **working** in parallel.

### Common mistake

Thinking `async` makes heavy computation non-blocking. It only helps when the time is
spent waiting.

### Quick revision

`async`/`await` runs on the same isolate through the event loop. Waiting doesn't block;
heavy CPU work still does. Use `Isolate.run` for that.
