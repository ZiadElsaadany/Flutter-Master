# State Management — Interview Questions

## 1. When Is `setState` OK With Bloc/Riverpod/Provider?

### Question

> If you use Bloc, Cubit, Riverpod or Provider, when can you still use `setState`
> without breaking state management or clean architecture?

### Answer

`setState` is the right tool for **ephemeral (local UI) state**. Flutter's docs use
that term: state that only one widget cares about, that no other screen needs, and
that holds no business logic. Examples: the selected tab, password visibility, whether
a card is expanded, a local animation, the current page of a `PageView`.

Use Bloc/Cubit for **app state**: data from APIs, state shared between widgets or
screens, anything with business rules, or anything you want to unit test.

```dart
class PasswordField extends StatefulWidget { /* ... */ }

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true; // purely visual, local: setState is fine

  @override
  Widget build(BuildContext context) => TextField(
        obscureText: _obscure,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
      );
}
```

### Mental model

Ask: "would any other widget, screen or test care about this value?" If not,
`setState`.

### Common mistake

The candidate said "many `setState` calls on one screen hurt performance". The
**number** of calls barely matters, because Flutter batches them into the next frame.
What matters is **how much** each one rebuilds. A `setState` high in a big screen
rebuilds everything below it. Move the state down into a small widget, like the
`PasswordField` above.

### Quick revision

`setState` for local, visual, non-shared state. State management for shared or
business state. Keep `setState` low in the tree.

## 2. Modelling States: Enums vs Sealed Classes vs Booleans

### Question

> For states like loading, success and error, do you use enums, sealed classes or
> boolean flags?

### Answer

- **Booleans** (`isLoading`, `hasError`) allow **impossible states**, such as
  `isLoading && hasError` at the same time. Avoid them for status.
- **Enum** status: fine when the states don't carry different data. Often combined into
  **one state class** with `status` + `copyWith`, which keeps the old data visible while
  reloading. The Bloc docs show this pattern for forms and lists.
- **Sealed classes** (Dart 3): each state carries **its own data**
  (`Success(products)`, `Failure(message)`), and `switch` is **exhaustive**: the
  compiler errors if you forget a state.

```dart
sealed class ProductsState {}
final class ProductsLoading extends ProductsState {}
final class ProductsLoaded extends ProductsState {
  ProductsLoaded(this.products);
  final List<Product> products;
}
final class ProductsFailure extends ProductsState {
  ProductsFailure(this.message);
  final String message;
}

Widget build(BuildContext context) => switch (state) {
      ProductsLoading() => const CircularProgressIndicator(),
      ProductsLoaded(:final products) => ProductList(products),
      ProductsFailure(:final message) => ErrorView(message),
    };
```

### Mental model

Make impossible states **unrepresentable**.

### Common mistake

The candidate said "enums for small things, separate classes for big projects", which
is a size rule. Choose by **data and correctness** instead: does each state carry
different data, and do you want exhaustive checks?

### Quick revision

Avoid boolean flags. Use an enum + `copyWith` when you keep data across states. Use
sealed classes when each state has its own data and you want exhaustive `switch`.

## 3. Same States Across Many Features: Duplication?

### Question

> Ten features all have the same states (loading, success, failure). Isn't that
> duplication? Do you define them per feature, or a shared parent and inherit?

### Answer

Use a **generic shared state** for the common pattern, and feature-specific states only
where a feature really differs. Reuse here is **DRY**. It doesn't violate SOLID, as
long as the shared type stays small and doesn't force features to depend on things
they don't use.

```dart
sealed class AsyncState<T> {
  const AsyncState();
}
final class Idle<T> extends AsyncState<T> { const Idle(); }
final class Loading<T> extends AsyncState<T> { const Loading(); }
final class Success<T> extends AsyncState<T> {
  const Success(this.data);
  final T data;
}
final class Failure<T> extends AsyncState<T> {
  const Failure(this.error);
  final AppFailure error;
}

class ProductsCubit extends Cubit<AsyncState<List<Product>>> { /* ... */ }
class ProfileCubit extends Cubit<AsyncState<User>> { /* ... */ }
```

A `sealed` class can only be subclassed in its own library. So features **use**
`AsyncState<T>` with their own type; they don't extend it. Riverpod's `AsyncValue` is
the same idea built in.

When a feature needs more (for example a login flow with `OtpRequired`), give that
feature its own sealed state.

### Mental model

Shared **shape**, feature-specific **data** through the generic type.

### Common mistake

The candidate claimed "sharing states breaks the SOLID principles". It doesn't. What
breaks things is a bloated base class that every feature must inherit, not a small
generic type.

### Quick revision

A generic `AsyncState<T>` (or Riverpod's `AsyncValue`) for the common case. Custom
sealed states only where the feature really differs.
