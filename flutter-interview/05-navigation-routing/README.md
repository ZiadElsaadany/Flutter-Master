# Navigation & Routing — Interview Questions

## 1. Pass the Whole Object or Only Its ID?

### Question

> When navigating to a new screen, do you pass the whole object as a parameter, or only
> its ID and load the object inside the new screen? Which do you prefer and why?

### Answer

It's a trade-off:

| Pass the object | Pass the ID |
|---|---|
| Instant render, no extra request | Needs a fetch (or a cache lookup) |
| Can be **stale** | Always fresh: one source of truth |
| Not in the URL: lost on deep links, web refresh, state restoration | Works with **deep links** and web URLs |

A common choice: put the **ID in the route path**, optionally pass the object as `extra`
to show something instantly, and have the screen load by ID when `extra` is missing or
to refresh.

```dart
GoRoute(
  path: '/products/:id',
  builder: (context, state) => ProductScreen(
    id: state.pathParameters['id']!,
    initial: state.extra as Product?, // optional, for an instant first frame
  ),
);

context.push('/products/${product.id}', extra: product);
```

### Mental model

The URL should be enough to rebuild the screen. Anything else is only an optimization.

### Common mistake

The candidate described a project that "passed the whole previous screen to get a
parameter". That couples screens together and should be avoided. They also didn't name
the real trade-off: deep links and staleness.

### Quick revision

ID in the path (deep-link safe, fresh). Object as optional `extra` for speed. Load by
ID when it is missing.

## 2. Protecting Screens That Need Authentication

### Question

> With GoRouter (or any router), how do you make sure the user can't open a screen that
> needs authentication unless they're logged in, including when they open the app
> after the token expired or through a deep link?

### Answer

Use a **route guard**. With GoRouter that is the top-level `redirect`, re-run whenever
auth state changes through `refreshListenable`. The guard checks **local** auth state
without calling the backend: is there a **refresh token / session** in secure storage
(and, if you know its expiry, is it still valid)? It sends logged-out users to `/login`
and remembers where they were going.

An **expired access token is not "logged out"**. Access tokens are short-lived, so
redirecting on them would send users to login on almost every app start. An expired
access token triggers a **refresh** instead (in the interceptor, see
[Networking](../06-networking-apis/README.md#3-avoiding-duplicate-token-refreshes),
or once at startup). Only a **failed refresh** clears the tokens. That flips the auth
state, and the guard redirects automatically.

The backend still enforces access with `401`.

```dart
final router = GoRouter(
  refreshListenable: authNotifier, // notifies on login/logout
  redirect: (context, state) {
    final loggedIn = authNotifier.hasSession; // refresh token stored, not cleared
    final goingToLogin = state.matchedLocation == '/login';

    if (!loggedIn && !goingToLogin) {
      return '/login?from=${Uri.encodeComponent(state.uri.toString())}';
    }
    if (loggedIn && goingToLogin) {
      return state.uri.queryParameters['from'] ?? '/';
    }
    return null; // no redirect
  },
  routes: [/* ... */],
);
```

### Mental model

The client guard is for **UX**. The server is the **security boundary**.

### Common mistake

The candidate talked about handling status codes after calling the API. The question
was how to block navigation **before** calling anything. Also, "no network" doesn't
return a status code at all (see [Networking](../06-networking-apis/README.md)).

### Quick revision

GoRouter `redirect` + `refreshListenable` on local session state (refresh token).
An expired access token means refresh, not redirect. Remember the target route with
`from`. The server's 401 is the final check.

## 3. Deep Linking

### Question

> How do you handle deep links, for example when the app is closed and the user taps a
> link that should open a specific screen? When would you need deep linking at all?

### Answer

**Why:** shared content (a product or post someone sent you), password-reset or
verification emails, marketing campaigns, and notifications. The user lands directly
on the right screen instead of navigating category → brand → item.

**How:**

1. **Platform setup** (verified HTTPS links):
   - Android **App Links**: an `intent-filter` with `android:autoVerify="true"` in
     `AndroidManifest.xml`, plus `/.well-known/assetlinks.json` on your domain.
   - iOS **Universal Links**: the Associated Domains entitlement
     (`applinks:example.com`), plus `/.well-known/apple-app-site-association` on your
     domain.
   - Custom schemes (`myapp://`) are easier but unverified. Any app can claim them.
2. **Routing:** since Flutter 3.27, Flutter's built-in deep link handling is **on by
   default** and passes the link to the router. With GoRouter, a path like
   `/products/42` just works if that route exists. If you use a package such as
   `app_links` or an attribution SDK, turn the built-in handling off
   (`FlutterDeepLinkingEnabled` in `Info.plist`, `flutter_deeplinking_enabled`
   meta-data on Android).
3. **Cold start vs warm start:** test both. When the app was killed, the link becomes
   the **initial** route.
4. **Auth:** the guard from question 2 redirects to login with `from=`, then continues
   to the linked screen.

Firebase Dynamic Links **shut down on 25 August 2025**. Don't propose it. Use App Links
and Universal Links directly, or a third-party link service.

### Mental model

The website proves the app owns the domain. The OS opens the app. The router turns the
path into a screen.

### Common mistake

The candidate hadn't used deep links and only described a "share app" store link. The
e-commerce example they gave (skip category → brand → item) is a good **use case**.
Pair it with the setup steps above.

### Quick revision

App Links (Android) and Universal Links (iOS) plus the `.well-known` files on your
domain. The router maps the path to a screen. Handle cold starts and auth redirects.
Firebase Dynamic Links is gone.
