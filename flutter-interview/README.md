# Flutter Interview Notes

Revision notes built from Flutter mock-interview videos. Questions are grouped by
topic, so a question asked in several videos lives in **one** section, with the best
answer.

Each question has: **Question** (what the interviewer asked) → **Answer** (what to say
out loud) → code → **Mental model** → **Common mistake** (what the candidate got wrong)
→ **Quick revision**.

## Sources

1. Arabic Flutter mock interview (~1h22m), covering all 14 topics below.

## Topics

1. [Dart Language](01-dart-language/README.md)
   - `var` vs `final` vs `const` vs `dynamic` vs `late`
   - Sequential vs parallel API calls
   - Does `async`/`await` run on another thread?
2. [Flutter Framework](02-flutter-framework/README.md)
   - API calls inside `build()`
   - Keys vs `BuildContext`
   - Widget vs Element vs RenderObject trees
3. [Responsive & Adaptive UI](03-responsive-adaptive-ui/README.md)
   - Responsive vs adaptive
   - Many layouts without breaking Open/Closed
4. [State Management](04-state-management/README.md)
   - When `setState` is OK
   - Enums vs sealed classes vs booleans
   - Shared states across features
5. [Navigation & Routing](05-navigation-routing/README.md)
   - Pass the object or its ID
   - Protecting authenticated screens (route guards)
   - Deep linking
6. [Networking & APIs](06-networking-apis/README.md)
   - Handling non-2xx responses app-wide
   - Retrying failed requests
   - Avoiding duplicate token refreshes
7. [Architecture](07-architecture/README.md)
   - Why logic doesn't belong in widgets
   - Service vs repository
   - Does every feature need a use case?
8. [Storage & Caching](08-storage/README.md)
   - Where to store theme, locale and tokens
   - Knowing when cached data is stale
   - Offline-first and the outbox
9. [Testing](09-testing/README.md)
   - Unit vs widget vs integration tests
   - What to test before handing to QA
   - Testing time, connectivity, location, unready APIs
10. [Performance](10-performance/README.md)
    - Debugging a slow screen
    - Reducing rebuilds
    - When you need an isolate
11. [Native Development](11-native-development/README.md)
    - Plugins that behave differently per platform
    - Native SDKs without a plugin
    - Background tasks: Android vs iOS
12. [Security](12-security/README.md)
    - Where to keep API keys
    - Making reverse engineering harder
13. [Git](13-git/README.md)
    - Resolving merge conflicts
    - Rebase
    - Hotfix while mid-feature (`git worktree`)
14. [AI in Development](14-ai-usage/README.md)
    - AI rules and skills
    - Context in AI tools
    - Accepting AI-generated code

## Terms to Know by Name

The candidate often knew the idea but said "I don't know what it's called".
Interviewers check vocabulary, so learn these names:

| Term | One line |
|---|---|
| Type inference | `var` gets its type from the first value |
| Event loop | How `async` code runs on one thread |
| Isolate | Dart's unit of parallelism: separate memory, `Isolate.run` |
| Element tree | Long-lived instances that hold State and connect widgets to render objects |
| Ephemeral state | Local UI state, where `setState` is fine |
| Sealed class / exhaustive switch | Dart 3 state modelling |
| Route guard / redirect | GoRouter's way to block unauthenticated screens |
| App Links / Universal Links | Verified deep links on Android / iOS |
| Single-flight refresh | One token refresh, all `401`s await it |
| Idempotent request / idempotency key | Safe to retry without duplicates |
| Exponential backoff | Retry waits that grow: 1 s, 2 s, 4 s… |
| Stale-while-revalidate / ETag | Cache invalidation strategies |
| Offline-first / outbox | Local DB as source of truth, queued sync |
| Dependency injection / fake / mock | How to test code with external dependencies |
| Platform channel / Pigeon / FFI | Calling native code from Dart |
| Obfuscation / attestation / certificate pinning | Making apps harder to tamper with |
| Rebase / revert / reset | Three different Git operations |
| Git worktree | A second folder checked out on another branch |
| AI rules / skills / context window | How coding agents are guided |
