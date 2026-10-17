# Storage & Caching — Interview Questions

## 1. Where to Store Theme, Locale and Tokens

### Question

> You need to cache the theme (dark/light), the language, and the JWT token. Do you
> store them all in the same place, for example SharedPreferences or SQLite? On what
> basis?

### Answer

Choose by **sensitivity** and **shape** of the data:

| Data | Store | Why |
|---|---|---|
| Theme, locale, onboarding seen | `shared_preferences` | Small, non-sensitive key-value data. Stored as **plain text**. |
| Access/refresh tokens, secrets | `flutter_secure_storage` | Encrypted: **Keychain** on iOS, Keystore-backed encryption on Android. |
| Structured or large data (offline lists, outbox) | SQLite (`sqflite`, `drift`) | Queries, relations, many rows. |

For `shared_preferences`, new code should use `SharedPreferencesAsync` or
`SharedPreferencesWithCache`. The plugin docs say the old `SharedPreferences` API will
be deprecated. Also, `shared_preferences` doesn't guarantee writes reach disk, so don't
store critical data there.

```dart
final prefs = SharedPreferencesAsync();
await prefs.setString('themeMode', 'dark');

const secure = FlutterSecureStorage();
await secure.write(key: 'accessToken', value: token);
final saved = await secure.read(key: 'accessToken');
```

### Mental model

Preferences for **settings**, secure storage for **secrets**, a database for **data**.

### Common mistake

The candidate first said everything goes in SharedPreferences, and only remembered
secure storage after the interviewer pointed out that tokens are sensitive. Lead with
the sensitivity split.

### Quick revision

Theme/locale in `shared_preferences` (plain text). Tokens in `flutter_secure_storage`.
Structured data in SQLite or drift.

## 2. Knowing When Cached Data Is Stale

### Question

> You cache the user's profile (name, photo) so you don't fetch it every time the home
> screen opens. The user changes their photo from another device. How do you know the
> cached profile is no longer valid?

### Answer

Pick an **invalidation strategy**:

- **TTL:** store `fetchedAt` and refetch after N minutes.
- **Stale-while-revalidate:** show the cached profile instantly, fetch in the
  background, and update the UI if it changed. This is the most common choice for
  profiles.
- **Conditional requests:** send `If-None-Match` (ETag) or `If-Modified-Since`. The
  server returns **304 Not Modified** with no body when nothing changed.
- **Version or `updatedAt` field:** a cheap endpoint or a field in another response
  tells you if your copy is old.
- **Push invalidation:** a silent push (FCM) or WebSocket event says "profile changed".
- Refresh on **app resume** and on **pull-to-refresh**.

For **images**: `cached_network_image` caches by URL. If the backend reuses the same URL
for a new photo, you keep showing the old one. The backend should return a
**versioned URL** (a new filename or `?v=<updatedAt>`).

```dart
Stream<User> watchProfile() async* {
  final cached = await _cache.readProfile();
  if (cached != null) yield cached;           // instant
  final fresh = await _api.fetchProfile();    // revalidate
  if (fresh != cached) {                      // needs value equality
    await _cache.saveProfile(fresh);
    yield fresh;
  }
}
```

### Mental model

Every cache needs an answer to "when do I stop trusting this?".

### Common mistake

The candidate mentioned "a boolean from the backend", which is close to a version
flag. They also mentioned "the immutable package that only rebuilds if the state
changed", which is about **rebuilds** (`equatable`), not cache validity.

### Quick revision

TTL, stale-while-revalidate, ETag/304, version fields, push invalidation. Images need
versioned URLs.

## 3. Offline-First: Queuing Actions Without Internet

### Question

> The user changes their name with no internet, then creates a post, still offline. How
> do you send these when the connection comes back? Do you track connectivity
> app-wide? (The interviewer asked about **offline-first** architecture.)

### Answer

In an **offline-first** design, the **local database is the source of truth**. The UI
always reads from local storage, and the network is used for syncing.

1. **Write locally first** and update the UI immediately (an optimistic update, marked
   "pending").
2. Add the operation to an **outbox** table: `id`, `type`, `payload`, `createdAt`,
   `attempts`.
3. A **sync engine** drains the outbox **in order** (rename before post) when:
   connectivity returns, the app starts or resumes, or a background job runs
   (`workmanager`).
4. Send an **idempotency key** with each operation so a retry can't create duplicates.
5. Handle **conflicts**: last-write-wins, server-wins, or a merge rule per field.
6. Remove the item on success. Retry with backoff on failure, and surface permanent
   failures to the user.

`connectivity_plus` only tells you the **network type** (Wi-Fi, mobile). It doesn't
tell you whether the internet actually works. Use it as a trigger, and treat a request
failing as the real signal.

```dart
Future<void> drainOutbox() async {
  for (final op in await _db.pendingOps(orderBy: 'createdAt')) {
    try {
      await _api.send(op.type, op.payload, idempotencyKey: op.id);
      await _db.deleteOp(op.id);
    } on DioException {
      await _db.incrementAttempts(op.id);
      break; // keep order: stop at the first failure
    }
  }
}

connectivity.onConnectivityChanged.listen((_) => drainOutbox());
```

### Mental model

Local writes are instant and always succeed. Syncing is a separate job that can happen
later.

### Common mistake

The candidate hadn't heard the term **offline-first** and only described "a package
that checks connectivity". Connectivity is the trigger. The architecture is the local
source of truth plus an ordered, idempotent outbox.

### Quick revision

Local DB is the source of truth. Optimistic UI plus an outbox, drained in order with
idempotency keys. Plan for conflicts. Connectivity is only a hint.
