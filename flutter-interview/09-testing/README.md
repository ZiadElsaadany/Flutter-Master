# Testing — Interview Questions

## 1. Unit vs Widget vs Integration Tests

### Question

> Flutter has three kinds of tests: unit, widget and integration. What is the
> difference between them?

### Answer

| | Unit test | Widget test | Integration test |
|---|---|---|---|
| Tests | One function or class (validator, Bloc, repository) | One widget or screen in a test environment | The **whole app** on a device or emulator |
| Flutter needed? | No (`package:test`) | Test framework, no device (`flutter_test`) | Real device (`integration_test`) |
| Dependencies | Mocked or faked | Faked (fake Bloc or repository) | Real, or a staging backend |
| Speed | Milliseconds | Fast | Slow |
| How many | Many | Some | Few |

```dart
// Unit test: pure logic.
test('rejects passwords shorter than 6', () {
  expect(Password.tryParse('12345'), isNull);
});

// Widget test: build, interact, check what is on screen.
testWidgets('shows error for short password', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
  await tester.enterText(find.byKey(const Key('password')), '123');
  await tester.tap(find.text('Login'));
  await tester.pump();
  expect(find.text('Min 6 characters'), findsOneWidget);
});
```

`bloc_test` makes Bloc unit tests short. **Golden tests** (screenshot comparison) are a
useful extra form of widget test.

### Mental model

The test pyramid: many cheap unit tests at the bottom, a few expensive end-to-end
tests at the top.

### Common mistake

The candidate described **manual** test scenarios ("enter a valid email and invalid
password…") as unit tests. Those scenarios are good test *cases*. A unit test is
*code* that checks them automatically. Their search bar example is mostly logic
(filtering), which you'd unit test, with one widget test for the UI.

### Quick revision

Unit = logic, no UI. Widget = one widget in a test environment. Integration = whole app
on a device. Many unit, some widget, few integration.

## 2. What Do You Test Before Handing a Feature to QA?

### Question

> Before you confirm a feature works, do you ask the tester for test scenarios first?
> Or do you only test the happy path and leave the invalid and bad scenarios to the
> tester?

### Answer

Get the **acceptance criteria and test scenarios before coding**, from QA or the product
owner. Then build against them. Before handing over, I cover:

- The **happy path**.
- The obvious **edge states**: loading, empty, error, no network, invalid input, very
  long text, RTL/Arabic.
- **Automated tests** for the logic (unit tests for validators and Blocs).

QA then adds value with **exploratory**, regression and device testing, instead of
finding bugs I could have caught myself.

Each bug QA returns costs a full round trip (ticket, context switch, fix, retest), so
handing over happy-path-only work is usually slower overall.

### Mental model

The developer proves it works. QA tries to break it.

### Common mistake

The candidate said they test the happy path and let QA find the rest, because it's
faster. The interviewer's own example showed the cost: the "fast" developer kept
getting tickets back. Frame it as a deadline trade-off at most, never the default.

### Quick revision

Take acceptance criteria upfront. Cover happy path plus error, empty and loading
states. Automate the logic tests. Let QA explore.

## 3. Testing Code That Depends on Time, Connectivity, Location or an Unready API

### Question

> Some code depends on the current time, connectivity, Google Maps (latitude and
> longitude), or an external API that isn't ready yet. You don't control those. How do
> you test it?

### Answer

**Dependency injection plus fakes or mocks.** Never call `DateTime.now()`,
`Connectivity()` or `Geolocator` directly in logic. Hide each one behind a small
interface you inject, then pass a fake in tests.

- **Time:** inject a clock (`package:clock` with `withClock`, or a
  `DateTime Function()` parameter). Use `fake_async` for timers and debounce.
- **Connectivity:** a `ConnectivityService` interface. The fake emits offline and
  online on demand.
- **Location:** a `LocationService` interface. The fake returns fixed coordinates.
- **Unready API:** agree on the **contract** with the backend (Swagger/OpenAPI or a
  sample JSON), save it as a **fixture**, and implement a fake data source returning
  it. Swap in the real one later through DI.

```dart
abstract interface class ConnectivityService {
  Stream<bool> get isOnline;
}

class FakeConnectivity implements ConnectivityService {
  final _controller = StreamController<bool>.broadcast();
  void goOffline() => _controller.add(false);
  void goOnline() => _controller.add(true);
  @override
  Stream<bool> get isOnline => _controller.stream;
}

test('offer expires at midnight', () {
  final offer = Offer(endsAt: DateTime(2026, 1, 1));
  withClock(Clock.fixed(DateTime(2026, 1, 1, 0, 1)), () {
    expect(offer.isExpired, isTrue); // isExpired uses clock.now()
  });
});

// Mock with mocktail.
class MockProductsApi extends Mock implements ProductsApiService {}
when(() => api.fetchProducts())
    .thenAnswer((_) async => loadFixture('products.json'));
```

### Mental model

If you can't control it, put it behind an interface and inject a fake.

### Common mistake

The candidate described building the UI with **fake data** and checking it by eye
(long text, Arabic, English). That's useful for UI work, but it isn't testing the
time, connectivity or location dependency. The key words are **dependency injection**,
**fakes/mocks**, **fixtures**.

### Quick revision

Abstract each external dependency, inject it, and fake it in tests (clock, connectivity,
location, API fixtures). Use `mocktail` for mocks and `fake_async` for timers.
