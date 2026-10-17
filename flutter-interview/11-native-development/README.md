# Native Development — Interview Questions

## 1. Plugins That Work on Android but Not iOS (or the Reverse)

### Question

> Have you used plugins (camera, GPS/location, notifications)? Can a plugin work on
> Android and then fail on iOS during testing, or the reverse?

### Answer

Yes, often. Each platform has its own setup and permission model:

- **Android:** permissions in `AndroidManifest.xml`, plus **runtime requests** for
  dangerous permissions. Android 13+ also needs `POST_NOTIFICATIONS` at runtime.
  Background location is a separate permission with stricter rules.
- **iOS:** a **usage description** in `Info.plist` for each permission
  (`NSCameraUsageDescription`, `NSLocationWhenInUseUsageDescription`...). If it is
  missing, the app **crashes** when it accesses the feature. iOS shows the system
  dialog **only once**: after a denial you must send the user to Settings
  (`openAppSettings()`). Users can also choose "Allow once" or approximate location.
- Some plugins need extra native setup (minimum SDK or iOS version, Podfile changes,
  capabilities like Push Notifications or Background Modes).

So: read each plugin's **platform setup** section, handle denied and
permanently-denied states in the UI, and test on **both** platforms.

```dart
final status = await Permission.camera.request(); // permission_handler
switch (status) {
  case PermissionStatus.granted:
    openCamera();
  case PermissionStatus.permanentlyDenied:
    await openAppSettings(); // iOS: the dialog never shows again
  default:
    showExplanation();
}
```

### Mental model

One Dart API, two native contracts.

### Common mistake

The candidate covered the main point (permissions are declared in both platforms'
files). Add the iOS crash on a missing usage description, the "ask only once"
behavior, and the denied UI states.

### Quick revision

Android: manifest + runtime requests. iOS: `Info.plist` usage strings (or it crashes),
one prompt only, then Settings. Test both platforms.

## 2. Using a Native SDK Without an Existing Plugin

### Question

> Can you integrate a native SDK or native component directly, without a Flutter
> package or plugin? Or must you always use or create a package?

### Answer

Yes. Flutter has several interop options:

- **Platform channels:** `MethodChannel` (request/response), `EventChannel` (streams,
  like sensor updates), `BasicMessageChannel`. The native side is Kotlin/Java or
  Swift/Objective-C in the `android/` and `ios/` folders.
- **Pigeon:** generates **type-safe** channel code on both sides from one Dart
  definition. Prefer it over hand-written string channels.
- **FFI (`dart:ffi`)** for C/C++ libraries. **`jnigen` / `ffigen`** generate direct
  bindings to Java/Kotlin and Objective-C/Swift APIs.
- **Platform views** (`AndroidView`, `UiKitView`) to embed **native UI**, such as a
  native map or a payment SDK's card form.

If several apps will use it, wrap it in a local **plugin package**. A plugin is just
these same pieces, packaged.

```dart
// Dart side
const _channel = MethodChannel('com.example/battery');
Future<int> batteryLevel() async =>
    await _channel.invokeMethod<int>('getBatteryLevel') ?? -1;
```

```kotlin
// Android side (MainActivity.kt)
MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example/battery")
    .setMethodCallHandler { call, result ->
        if (call.method == "getBatteryLevel") result.success(readBatteryLevel())
        else result.notImplemented()
    }
```

### Mental model

Plugins aren't magic. They are platform channels (or FFI) with a nice Dart API.

### Common mistake

The candidate had only used plugins, and knew from colleagues that "payment was done
natively". Name the mechanism: **platform channels**, **Pigeon**, **FFI**, **platform
views**.

### Quick revision

MethodChannel/EventChannel (with Pigeon for type safety), FFI with jnigen/ffigen,
platform views for native UI. Package it as a plugin to reuse it.

## 3. Background Tasks: Android vs iOS

### Question

> If you run a background task (tracking location, or whether the app is in the
> foreground or background), is the behavior identical on Android and iOS? Do you
> handle it natively per platform, in Flutter, or both?

### Answer

It is **very different**, and the difference is in the OS, not the UI:

- **Android:** `WorkManager` for deferrable work (periodic minimum **15 minutes**),
  **foreground services** with a visible notification for continuous work such as
  tracking (Android 14+ requires a declared service type), and Doze/App Standby limits.
  Some manufacturers also kill background apps aggressively.
- **iOS:** much stricter. The app is **suspended** shortly after going to the
  background. `BGTaskScheduler` (app refresh / processing tasks) runs **when the OS
  decides**, not on your schedule. Continuous work needs a specific **Background Mode**
  (location updates, audio, VoIP...), justified at App Store review. Significant
  location changes can wake the app.

In Flutter you use plugins (`workmanager`, background location plugins,
`flutter_background_service`) for a shared Dart API. They run Dart in a background
isolate or headless engine. You still configure **each platform natively** (manifest
entries, `Info.plist` background modes, entitlements), and sometimes write native code.
So it's both.

Design for "**may not run on time**": make tasks idempotent and resumable.

App lifecycle also differs. Use `AppLifecycleListener` (`resumed`, `inactive`,
`hidden`, `paused`, `detached`) and don't assume both platforms send the same sequence.

### Mental model

Android lets you ask to run in the background. iOS decides if you may.

### Common mistake

The candidate first answered about loading UI looking different. The interviewer
steered them to the real issue: the **lifecycle and background execution rules**.

### Quick revision

Android: WorkManager (≥15 min), foreground services. iOS: suspension, BGTaskScheduler
runs when the OS chooses, Background Modes. Plugins give one API; native config is
always per platform.
