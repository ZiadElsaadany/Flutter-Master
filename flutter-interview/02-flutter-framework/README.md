# Flutter Framework — Interview Questions

## 1. API Calls Inside `build()`

### Question

> Can you put an API call inside the `build` method of a `StatefulWidget`? Is that good
> or bad? If not, where do you put it so it isn't called on every rebuild?

### Answer

It's bad. `build` can run **many times**: on `setState`, when a parent rebuilds, when
`MediaQuery` changes (keyboard opens, rotation), when a theme changes. Each run would
fire the request again.

Put one-time loading in `initState`. With Bloc, trigger it when the Bloc is created, so
the screen only renders states. If you use `FutureBuilder`, create the future once in
`initState` and store it. Don't create it inside `build`.

```dart
// Bloc: load once, when the Bloc is created.
BlocProvider(
  create: (_) => ProductsBloc(getProducts)..add(const ProductsRequested()),
  child: const ProductsView(),
);

// FutureBuilder: the future is created once, not on every build.
class _ProfileState extends State<Profile> {
  late final Future<User> _user = api.getUser();

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: _user,
        builder: (context, snapshot) => /* ... */,
      );
}
```

### Mental model

`build` must be a **pure description** of the UI for the current state: fast and free
of side effects.

### Common mistake

The candidate first said "use a StatefulWidget because the data is dynamic". That isn't
the point. The point is that `build` is called repeatedly, so side effects there repeat.

### Quick revision

No side effects in `build`. Load in `initState` or Bloc creation, and cache futures.

## 2. Keys vs BuildContext

### Question

> What are keys and why do we need them? How are they different from `BuildContext`?
> Give a real use case from a project.

### Answer

When Flutter rebuilds, it matches new widgets to existing **Elements** by
`runtimeType` and **key**. Without keys, two widgets of the same type are matched by
**position**. If items in a list are reordered, removed or inserted, the State (text
input, checkbox, animation) can stay attached to the wrong item. A key gives a widget a
stable **identity**, so its State follows it.

- `ValueKey(item.id)` / `ObjectKey(item)`: identity from data. This is the most common
  choice in lists.
- `UniqueKey()`: a new identity every time it is created. Use it to **force** a widget
  to be recreated.
- `GlobalKey`: unique across the whole app. It gives access to a widget's `State` or
  `BuildContext` from outside, for example `GlobalKey<FormState>` for validation, or a
  `navigatorKey` / `scaffoldMessengerKey`. GlobalKeys are relatively expensive, so use
  them sparingly.

`BuildContext` is different. It is the widget's **location in the tree** (it *is* the
Element), and you use it to look up ancestors: `Theme.of(context)`,
`context.read<Bloc>()`, `Navigator.of(context)`. Every widget has one. A key is
optional and only affects how the framework matches widgets during a rebuild.

```dart
// Reorderable/dismissible lists need keys so State follows the item.
ListView(
  children: [
    for (final todo in todos)
      Dismissible(key: ValueKey(todo.id), child: TodoTile(todo)),
  ],
);

// GlobalKey to reach a State from outside.
final _formKey = GlobalKey<FormState>();
Form(key: _formKey, child: /* fields */);
if (_formKey.currentState!.validate()) { /* submit */ }
```

Real use cases: `Dismissible` (requires a key), `ReorderableListView`, form validation
with `GlobalKey<FormState>`, and `AnimatedSwitcher` (it needs a different key to detect
that its child changed).

### Mental model

The **key** answers "is this the same widget as before?". The **context** answers
"where am I in the tree?".

### Common mistake

The candidate said keys are used to "select specific data from a nested API list".
That is wrong: keys are about widget identity during rebuilds, not about data. They
also invented "unique key / variable key" categories. The real types are listed above.

### Quick revision

A key keeps a widget's identity (and State) across rebuilds, especially in lists.
Context is the widget's position in the tree, used for lookups.

## 3. Widget Tree vs Element Tree vs RenderObject Tree

### Question

> Flutter has three main trees: the widget tree, the element tree and the render object
> tree. What is the difference?

### Answer

- **Widget tree:** immutable **configuration**, the code you write. Widgets are cheap
  and are recreated on every rebuild.
- **Element tree:** the **living instance** of each widget at a location in the tree.
  Elements are long-lived and mutable. They hold `State` for stateful widgets, manage
  the lifecycle, and on rebuild compare the old and new widget
  (`Widget.canUpdate`: same `runtimeType` and `key`). If the widget can update, the
  element keeps its State and updates its render object. Otherwise it creates new ones.
- **RenderObject tree:** does the expensive work: **layout** (sizes, positions),
  **paint**, and hit testing. Render objects are kept and updated, not rebuilt.

This split is why Flutter can rebuild widgets constantly and stay fast: only the cheap
layer is thrown away.

```text
Widget (Text('Hi'))  →  Element (StatelessElement)  →  RenderObject (RenderParagraph)
     cheap, immutable       long-lived, holds State         layout + paint
```

### Mental model

Widget = blueprint. Element = the manager on site. RenderObject = the actual building.

### Common mistake

The candidate had never heard of the element tree and confused this topic with a
pub.dev package for comparing state (that is something like `equatable`, which does
value equality and is unrelated). Remember that the **Element** is the layer between
widgets and render objects.

### Quick revision

Widgets describe, Elements manage (identity, State, lifecycle), RenderObjects lay out
and paint.
