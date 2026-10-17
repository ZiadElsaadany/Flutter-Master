# Performance Optimization — Interview Questions

## 1. Debugging a Slow Screen

### Question

> One screen is heavy and slow. How do you find the cause? What do you actually do to
> trace which problem it is?

### Answer

**Measure first, guess later:**

1. Run in **profile mode** (`flutter run --profile`) on a **real device**. Debug mode
   is much slower and gives misleading results.
2. Open **DevTools → Performance**. Look for janky frames and check which thread is
   slow:
   - **UI thread** slow: too much work in `build`/layout, too many rebuilds, or
     expensive Dart code (parsing, sorting).
   - **Raster thread** slow: expensive painting such as `saveLayer` from `Opacity`,
     clips, shadows, large images.
3. Use **Track widget rebuilds** / rebuild stats to see what rebuilds too often.
4. Use the **CPU profiler** to find hot functions.
5. Check the **Memory** view (leaks, huge images) and the **Network** view (slow or
   duplicated calls).

Then fix the cause and **measure again**.

### Mental model

Find which thread is late, then which code makes it late.

### Common mistake

The candidate's approach was "turn off the API calls and see if it gets faster". Removing
parts one by one is a valid **last resort**, but you should start with DevTools.

### Quick revision

Profile mode on a real device → DevTools Performance (UI vs raster thread) → rebuild
stats → CPU profiler → fix → re-measure.

## 2. Reducing Rebuilds

### Question

> You mentioned reducing rebuilds. How do you actually reduce them?

### Answer

- **`const` constructors**: a `const` widget is reused, not rebuilt.
- **Split big widgets into small widget classes**, not helper methods that return
  widgets. A separate class gets its own Element and can skip rebuilding.
- **Push state down**: call `setState` in the smallest widget that owns the state.
- **Rebuild only on what changed**: `BlocBuilder(buildWhen: ...)`, `BlocSelector`,
  `context.select`, `ValueListenableBuilder`.
- Pass static subtrees as the **`child`** argument of `AnimatedBuilder` /
  `ListenableBuilder`, so they aren't rebuilt on every tick.
- Use **lazy lists**: `ListView.builder` instead of `ListView(children: [...])` for long
  lists.
- Keep `build` **cheap**: no sorting, parsing or object creation that could be done
  once.
- `RepaintBoundary` reduces **repaints** (not rebuilds) of parts that change often.

```dart
// Only rebuilds when the cart count changes, not on every CartState change.
BlocSelector<CartBloc, CartState, int>(
  selector: (state) => state.items.length,
  builder: (context, count) => Badge(label: Text('$count'), child: const CartIcon()),
);
```

Correctness counts as performance too. The candidate described a handed-over app where a
failed API call kept the screen **loading forever**. Every `try` in a Bloc must emit a
failure state in `catch`.

### Mental model

Rebuild the **smallest** part, only when **its** data changes.

### Common mistake

The candidate talked about reviewing old code and counting `setState` calls, but named
none of the tools (`const`, `buildWhen`, `BlocSelector`, splitting into widgets).

### Quick revision

`const`, small widget classes, state low in the tree, `buildWhen`/`select`, the `child`
parameter, builder lists, cheap `build`.

## 3. When Do You Need an Isolate?

### Question

> The widget tree is fine and the API responds fast, but the screen still freezes.
> When is an isolate the solution?

### Answer

When the problem is **CPU-heavy Dart work on the main isolate**. At 60 fps a frame
has about **16 ms**, and any synchronous work longer than that drops frames. `async`
doesn't help here (see [Dart: async](../01-dart-language/README.md#3-does-asyncawait-run-on-another-thread)).

Typical cases: parsing a **huge JSON** response (the interviewer's example: 100,000
lines), image processing, encryption or hashing, compressing files, searching or
sorting a big list.

- `Isolate.run(() => work())`: one-off task, returns the result. `compute()` is
  Flutter's older helper for the same thing.
- `Isolate.spawn` + ports: a long-lived background worker.

Costs: isolates **don't share memory**. Whatever the closure captures is **copied in**,
so capture only what you need. `Isolate.run` sends the result back without copying
(through `Isolate.exit`). Spawning also takes time, and they can't touch widgets. Platform
channels from a background isolate need `BackgroundIsolateBinaryMessenger`.

Not needed for network I/O: waiting doesn't block.

```dart
Future<List<Product>> parseProducts(String body) {
  return Isolate.run(() {
    final list = jsonDecode(body) as List<dynamic>;
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  });
}
```

### Mental model

Async helps with **waiting**. Isolates help with **working**.

### Common mistake

The candidate answered with **pagination** (loading 25 users at a time). Pagination
fixes **too much data** (memory, rendering, network). It doesn't fix one heavy
computation blocking a frame.

### Quick revision

Isolates are for CPU work longer than a frame (huge JSON, images, crypto).
`Isolate.run` for one-off tasks. No shared memory. Not for I/O.
