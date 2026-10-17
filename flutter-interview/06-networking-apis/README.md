# Networking & APIs — Interview Questions

## 1. Handling Non-2xx HTTP Responses App-Wide

### Question

> How do you manage HTTP errors (anything that isn't 200/201) across the whole app?
> Where do you handle them?

### Answer

Handle them in **one place**, the network layer (a Dio client or interceptor), and turn
every error into a **typed failure** before it leaves the data layer. Repositories
return a result type. Blocs map failures to states, and the UI maps them to messages.
No widget ever sees a raw status code.

Status code ranges:

| Range | Meaning | Examples |
|---|---|---|
| 2xx | Success | 200 OK, 201 Created, 204 No Content |
| 3xx | Redirection | 304 Not Modified |
| 4xx | Client error | 400, 401 Unauthorized, 403 Forbidden, 404, 422 validation, 429 rate limit |
| 5xx | Server error | 500, 502, 503, 504 |

No internet and timeouts have **no status code**. In Dio they arrive as
`DioExceptionType.connectionError` or `connectionTimeout`.

```dart
sealed class AppFailure { const AppFailure(); }
final class NoConnection extends AppFailure { const NoConnection(); }
final class Unauthorized extends AppFailure { const Unauthorized(); }
final class ValidationFailure extends AppFailure {
  const ValidationFailure(this.fields);
  final Map<String, String> fields;
}
final class ServerFailure extends AppFailure {
  const ServerFailure(this.statusCode);
  final int? statusCode;
}

AppFailure mapDioError(DioException e) => switch (e.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout => const NoConnection(),
      _ => switch (e.response?.statusCode) {
          401 => const Unauthorized(),
          422 => ValidationFailure(parseFieldErrors(e.response?.data)),
          final code => ServerFailure(code),
        },
    };
```

### Mental model

Status codes are a **transport detail**. The rest of the app should speak in failures.

### Common mistake

The candidate said a missing network "returns a different status code". It doesn't:
the request never reaches a server. They also described the ranges vaguely
("300 and above is a range"). Know the five classes.

### Quick revision

One network layer maps errors to a sealed `AppFailure`. Know 2xx–5xx. No connection
means no status code.

## 2. Retrying Failed Requests

### Question

> A request fails because of the user's network (bad Wi-Fi, no data left). Should the
> app retry automatically until the server responds, or not? What about a silent retry
> without the user doing anything?

### Answer

Retry **automatically and silently**, but only when it's safe:

- **Only transient errors:** timeouts, connection errors, 502/503/504, and 429 (respect
  `Retry-After`). **Never** retry 4xx errors like 400, 401 or 404: the same request
  will fail again. 401 goes to the token refresh flow instead (question 3).
- **Only idempotent requests:** GET, PUT, DELETE. Retrying a **POST** (create order,
  pay) can create duplicates or double charges, unless the backend supports an
  **idempotency key**.
- **Exponential backoff with jitter** (for example 1 s, 2 s, 4 s plus randomness) and a
  **max attempts** limit. Then show an error with a manual "Retry" button.

```dart
Future<T> withRetry<T>(Future<T> Function() request, {int maxAttempts = 3}) async {
  for (var attempt = 1; ; attempt++) {
    try {
      return await request();
    } on DioException catch (e) {
      final idempotent =
          const {'GET', 'HEAD', 'PUT', 'DELETE'}.contains(e.requestOptions.method);
      final transient = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          const {429, 502, 503, 504}.contains(e.response?.statusCode);
      if (!idempotent || !transient || attempt == maxAttempts) rethrow;
      final delayMs = 500 * (1 << attempt) + Random().nextInt(300);
      await Future.delayed(Duration(milliseconds: delayMs));
    }
  }
}
```

### Mental model

Retry what is **temporary** and **safe to repeat**. Everything else fails fast.

### Common mistake

The candidate said not to retry because "mobile prices change several times an hour,
so the second call could return different prices". A retry simply returns the current
prices, which is what you want. The real risk is **non-idempotent side effects**.

### Quick revision

Silent retry for transient errors on idempotent requests, with backoff and a limit.
Never blindly retry POSTs or 4xx errors.

## 3. Avoiding Duplicate Token Refreshes

### Question

> The access token expired. Several requests hit the server at the same time and all
> get `401`, so all of them call the refresh endpoint and you get several new tokens.
> How do you make sure the refresh happens only once?

### Answer

Use a **single-flight refresh**. The first `401` starts the refresh and stores its
`Future`. Every other `401` that arrives meanwhile **awaits the same future**, then
retries with the new token.

One more race: a request that was sent with the **old** token may fail *after* the
refresh already finished. So before refreshing, compare the token that request used
with the current one. If they differ, just retry with the current token.

Use a separate Dio instance (without this interceptor) for the refresh call, so it
can't loop. If the refresh fails, log out once.

```dart
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._dio, this._refreshDio, this._tokens);

  final Dio _dio;        // main client (has this interceptor)
  final Dio _refreshDio; // plain client used only for /refresh
  final TokenStore _tokens;
  Future<String?>? _refreshing; // the one in-flight refresh

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokens.access();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    if (err.response?.statusCode != 401 || options.extra['retried'] == true) {
      return handler.next(err);
    }

    final usedToken = options.headers['Authorization'];
    final current = await _tokens.access();
    final String? newToken;
    if (current != null && 'Bearer $current' != usedToken) {
      newToken = current; // someone already refreshed
    } else {
      newToken = await (_refreshing ??=
          _refresh().whenComplete(() => _refreshing = null));
    }
    if (newToken == null) return handler.next(err); // refresh failed: logged out

    options
      ..headers['Authorization'] = 'Bearer $newToken'
      ..extra['retried'] = true;
    try {
      handler.resolve(await _dio.fetch(options));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<String?> _refresh() async {
    try {
      final res = await _refreshDio.post('/auth/refresh',
          data: {'refreshToken': await _tokens.refresh()});
      await _tokens.save(res.data['access'], res.data['refresh']);
      return res.data['access'] as String;
    } catch (_) {
      await _tokens.clear(); // the router guard sends the user to login
      return null;
    }
  }
}
```

Dio's `QueuedInterceptor` is an alternative: it processes interceptor calls one at a
time, so the second `401` only runs after the first refresh finished. You still need
the token comparison.

### Mental model

One refresh, many waiters.

### Common mistake

The candidate's answer was "cache the token and compare it". The comparison is part of
the answer, but without a shared in-flight future, concurrent `401`s still start
several refreshes.

### Quick revision

Store the refresh `Future` and let every `401` await it. Compare tokens to catch late
`401`s. Refresh with a separate client. Retry once, and log out if the refresh fails.
