# Architecture — Interview Questions

## 1. Why Business Rules and API Calls Don't Belong in Widgets

### Question

> Why don't we put API calls or business rules in the widget? What is the widget
> responsible for, and where do business rules and API calls go in clean architecture?
> For example, "the password must be at least 6 characters": where does that rule go?

### Answer

A widget has two jobs: **render the current state** and **forward user events**.
Everything else lives in a layer that can be tested and reused without Flutter:

| Layer | Holds |
|---|---|
| **Presentation** (widgets + Bloc/Cubit) | Widgets render state. The Bloc holds **presentation logic**: which state to emit, loading, mapping failures to messages. |
| **Domain** (entities, value objects, use cases, repository interfaces) | **Business rules**: password length, price calculations, eligibility. Pure Dart. |
| **Data** (repository implementations, data sources/services, DTOs) | API calls, caching, JSON mapping. |

Why: business rules in a widget can't be unit-tested without the UI, get duplicated
across screens, and run again on every rebuild.

The password rule is a **business rule**, so it belongs in the **domain**: a value
object or validator. The Bloc calls it and emits an error state, and the UI only shows
it. The backend should still validate too.

```dart
// domain/value_objects/password.dart
extension type Password._(String value) {
  static const minLength = 6;

  static Password? tryParse(String input) =>
      input.length >= minLength ? Password._(input) : null;
}

// presentation/bloc: uses the rule, doesn't define it
on<PasswordChanged>((event, emit) {
  final password = Password.tryParse(event.value);
  emit(state.copyWith(passwordError: password == null ? 'Min 6 characters' : null));
});
```

### Mental model

The UI asks "what should I show?". The domain answers "what is allowed?".

### Common mistake

The candidate said validation goes "in the use case, or in the Bloc if it's big", and
that "95% of my logic is in the Bloc". Size isn't the criterion. Business rules go in
the domain, and the Bloc only orchestrates. A Bloc full of business rules is just a
fat controller.

### Quick revision

Widgets render and forward events. Bloc = presentation logic. Domain = business rules.
Data = APIs and caching.

## 2. Service vs Repository

### Question

> The use case talks to the repository, and we also have something called a service.
> What is the difference between a service and a repository?

### Answer

Flutter's official architecture guide (docs.flutter.dev/app-architecture) defines:

- **Service** (also called a data source): wraps **one external thing**: a REST API,
  Firebase, a local database, the location SDK. It returns raw responses or DTOs and
  **holds no state**.
- **Repository:** the **source of truth** for one type of app data. It can **combine
  services** (remote + local cache), map DTOs to domain models, handle caching, retry
  and refresh, and convert exceptions into failures. The domain depends on the
  repository **interface**, never on a service.

```dart
class ProductsApiService {                      // talks to the API only
  Future<List<ProductDto>> fetchProducts() async { /* dio.get(...) */ }
}

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this._api, this._cache);
  final ProductsApiService _api;
  final ProductsCache _cache;

  @override
  Future<Result<List<Product>>> getProducts() async {
    try {
      final dtos = await _api.fetchProducts();
      await _cache.save(dtos);
      return Ok(dtos.map((d) => d.toDomain()).toList());
    } on DioException catch (e) {
      final cached = await _cache.read();
      return cached != null
          ? Ok(cached.map((d) => d.toDomain()).toList())
          : Err(mapDioError(e));
    }
  }
}
```

Note: some teams also use "service" for app-wide helpers (analytics, notifications).
Say which meaning you use.

### Mental model

A service knows **how to talk** to one source. A repository knows **what data the app
needs** and where to get it.

### Common mistake

The candidate listed their folder structure instead of answering. Lead with the
responsibilities.

### Quick revision

Service = one source, stateless, raw data. Repository = source of truth that combines
services, maps to domain models and handles caching and errors.

## 3. Does Every Feature Need a Use Case Class?

### Question

> Does every feature need a use case class? If the Cubit calls the use case and the use
> case only calls the repository, what does the use case add besides an extra file?

### Answer

Not necessarily. A **pass-through** use case (`call() => repo.getX()`) adds files and
no value. Flutter's architecture guide treats the domain/use-case layer as
**optional**: add a use case when it does real work:

- It **combines several repositories** (for example checkout = cart + payment + order).
- It holds **business logic** that doesn't belong to one repository.
- The same logic is **reused** by several Blocs or view models.

The layer separation (the data layer can't break the presentation layer) comes from
the **repository interface** (dependency inversion), not from pass-through use cases.

Some teams still require use cases everywhere for consistency. That's a valid team
rule, as long as you can say it is a convention and not a technical need.

```dart
// Worth a use case: orchestrates several repositories plus a rule.
class PlaceOrder {
  PlaceOrder(this._cart, this._payments, this._orders);
  final CartRepository _cart;
  final PaymentRepository _payments;
  final OrderRepository _orders;

  Future<Result<Order>> call() async {
    final cart = await _cart.current();
    if (cart.isEmpty) return const Err(EmptyCartFailure());
    final payment = await _payments.charge(cart.total);
    return _orders.create(cart, payment);
  }
}
```

### Mental model

A use case is justified by **what it does**, not by which layer it sits in.

### Common mistake

The candidate argued that use cases "isolate the data layer from the presentation
layer". That isolation comes from the repository abstraction. A use case that only
forwards a call doesn't add any.

### Quick revision

Add use cases for orchestration, real business logic or reuse. Skip pass-through ones
unless the team requires them, and say that it's a convention.
