# Security — Interview Questions

## 1. Where to Keep API Keys (Payment SDKs, Google Maps)

### Question

> Payment SDKs, Google Maps and other third parties give you an API key that you put in
> the app. Where do you put it so it isn't on Git (GitHub, GitLab, Bitbucket), even in
> the history? Is it OK to just leave it in the code?

(The video then continued the same question: "the repo is a private company account,
so only the team sees it.")

### Answer

Two separate problems:

**1. Keep it out of Git.**

- Don't hardcode it. Pass it at build time with `--dart-define` or
  `--dart-define-from-file=env.json`, and add `env.json` to `.gitignore`.
- In CI, inject it from the pipeline's **secret store**.
- Native keys (for example the Maps key in `AndroidManifest.xml` / `AppDelegate`)
  come from `local.properties` / xcconfig files that aren't committed.
- If a key was ever committed, **rotate it**. Deleting it in a later commit doesn't
  remove it from history.

```dart
// flutter run --dart-define-from-file=env.json
const mapsKey = String.fromEnvironment('MAPS_API_KEY');
```

**2. Accept that anything in the app binary can be extracted.** A key shipped inside
the APK/IPA is never truly secret, so:

- **Restrict** client keys: a Google Maps key limited to your package name + SHA-1 and
  your iOS bundle ID, and limited to the APIs you use.
- Keep **real secrets on the backend.** Payments: the app gets a **publishable** key or
  a client token, and the **secret key** stays on your server, which creates the
  payment. Same for AI APIs and anything billable: the app calls **your backend**, which
  calls the third party.

### Mental model

Git hygiene protects the **source**. Only the server protects the **secret**.

### Common mistake

The candidate said a private company repo is enough because "only the team can see
the source". Private repos leak (laptops, contractors, forks). More importantly, the
key ships inside the app, where anyone can extract it.

### Quick revision

No keys in source: `--dart-define-from-file` + CI secrets, and rotate if leaked.
Restrict client keys. Real secrets only on the backend.

## 2. Making Reverse Engineering Harder

### Question

> How do you reduce the chance that someone reverse-engineers your app: gets the
> source from the bundle, understands it, changes the app's behavior or repackages it?

### Answer

You can't make it impossible, only **harder**. And the server must never trust the
client.

- **Obfuscate Dart code:**
  `flutter build apk --obfuscate --split-debug-info=build/symbols`. Keep the symbol
  files to decode crash stack traces. Obfuscation only renames symbols. It doesn't
  encrypt assets or strings.
- **Android R8/ProGuard** shrinks and obfuscates the Android Java/Kotlin side in
  release builds. It doesn't touch Dart code or native `.so` libraries.
- **No secrets in the client** (see question 1).
- **App integrity / attestation:** Play Integrity API (Android), App Attest /
  DeviceCheck (iOS). The **backend** checks the attestation token, so a repackaged or
  tampered app gets rejected.
- **Root/jailbreak and debugger detection** for high-risk apps (banking).
- **Certificate pinning**, so the traffic can't be read or modified through a proxy
  (MITM).
- **Server-side validation of everything**: prices, roles, limits. A modified client
  can send anything.
- No sensitive logs in release builds. Tokens go in secure storage.

### Mental model

Each layer makes an attack more expensive. Server-side checks are the only part the
attacker doesn't control.

### Common mistake

The candidate said they hadn't worked on high-security apps and talked about company
laptop security (Kaspersky, locked keyboards), which is unrelated. Even without
experience, you can name the layers: **obfuscation**, **R8**, **attestation**,
**pinning**, **server-side validation**.

### Quick revision

`--obfuscate --split-debug-info`, R8, no client secrets, Play Integrity / App Attest
checked by the server, pinning, root detection, never trust the client.
