# SafeClick — Architecture Reference

> **Version:** Post-Refactoring MVP · 2026-02-27
> **For:** Future developers and AI agents continuing this project.
>
> Read this file **before** making any structural changes to the codebase.

---

## 1 · Current Architecture Summary

The app uses **MVVM-lite with Provider** across a flat feature-by-file structure.

```
lib/
├── controllers/          ← ViewModels (ChangeNotifier)
│   ├── auth_controller.dart
│   ├── scan_controller.dart
│   ├── settings_controller.dart
│   ├── profile_controller.dart
│   └── report_controller.dart
├── services/             ← Infrastructure (data access, API, notifications)
│   ├── local_storage_service.dart   ← single persistence gateway
│   ├── scan_service.dart
│   ├── api_service.dart
│   └── notification_service.dart
├── models/               ← Pure Dart domain models (NO Flutter imports)
│   ├── user_model.dart
│   ├── scan_result.dart
│   ├── settings_model.dart
│   └── report_model.dart
├── views/                ← Screens (UI only)
│   ├── auth/
│   ├── main/
│   ├── scan/
│   ├── profile/
│   ├── report/
│   ├── settings/
│   └── splash_screen.dart
├── widgets/              ← Reusable UI components + presentation extensions
│   ├── custom_button.dart
│   ├── profile_stats.dart
│   ├── stats_card.dart
│   └── scan_result_ui.dart          ← ScanResult color/icon extension (NEW)
├── theme/
│   └── app_theme.dart
└── main.dart             ← App root + shared service wiring
```

---

## 2 · Dependency Flow

```
Views / Widgets
      │  reads via Consumer / context.watch
      ▼
Controllers (ChangeNotifier)
      │  injected via constructor
      ▼
Services (stateless helpers)
      │  calls
      ▼
LocalStorageService  ────────────────────  SharedPreferences
ApiService           ─── HTTP (mocked) ─── Future network calls
NotificationService  ────────────────────  flutter_local_notifications

Models (pure Dart — no Flutter imports)
      ▲  used by all layers above
```

**Rule: dependencies only flow downward. Models never import Flutter.**

---

## 3 · Identified Structural Weaknesses (from audit)

These were found during the initial audit and have been resolved in this refactoring:

| Issue | Status |
|---|---|
| `ScanResult` imported `flutter/material.dart` (Color in model) | ✅ Fixed |
| `userId` regenerated on every login → history lost | ✅ Fixed |
| All controllers instantiated services internally (no DI) | ✅ Fixed |
| `ScanController` called `SharedPreferences` directly (3 places) | ✅ Fixed |
| `AuthController` called `SharedPreferences` directly (login/logout) | ✅ Fixed |
| `SettingsModel` fields were mutable (`var`) | ✅ Fixed |
| Null crash: `if (!shouldProceed)` on `bool?` from `showDialog` | ✅ Fixed |
| Multiple `LocalStorageService` instances created (one per controller) | ✅ Fixed |

**Known remaining items (deferred — out of MVP scope):**

| Issue | Priority | Notes |
|---|---|---|
| `blockedCount == dangerousCount` in `StatsCard` call | Medium | Logic error in `main_screen.dart:372` |
| `_generateTrackingNumber` is not truly random | Medium | Uses sequential timestamp |
| `intl` package imported but unused for date formatting | Low | Used for l10n declaration only |
| No tests exist | High | Should be added before scaling |
| `ProfileController` still has hardcoded mock user fallback | Medium | Intentionally kept, marked with `// ← MOCK` |

---

## 4 · Refactoring Decisions Made

### DI via Constructor (not a framework)

All controllers now accept their dependencies via named constructor parameters with defaults:

```dart
ScanController({ScanService? scanService, LocalStorageService? storageService})
    : _scanService = scanService ?? ScanService(),
      _storageService = storageService ?? LocalStorageService();
```

- The `?? Default()` fallback means **no callers need to change** if they don't pass arguments.
- `main.dart` passes a **single shared instance** to eliminate duplicate service state.
- This approach is intentionally minimal — no `get_it`, no `injectable`, no code generation.
- Upgrade to `get_it` when the project grows beyond ~10 controllers.

### SharedPreferences Access Consolidated

All reads/writes to `SharedPreferences` for auth session and scan history now go through `LocalStorageService` only:

| Previously scattered in | Now routed through |
|---|---|
| `auth_controller.dart` | `LocalStorageService.saveAuthSession()` / `clearAuthSession()` |
| `scan_controller.dart` | `LocalStorageService.saveScanHistory()` |
| `scan_service.dart` | ✅ Already used `LocalStorageService` (blacklist) — no change |

`SettingsController` is the **only** controller that still calls `SharedPreferences` directly. This is intentional — settings are scalar key-value pairs with no model relationship to other controllers.

### Presentation Extension Pattern

`ScanResult.safetyColor` has been moved out of the domain model into:

```
lib/widgets/scan_result_ui.dart
```

```dart
extension ScanResultPresentation on ScanResult {
  Color safetyColor(BuildContext context) { ... }
  IconData get safetyIcon { ... }
}
```

**Rule:** Any view/widget that needs colors or icons for a `ScanResult` must:
1. Import `widgets/scan_result_ui.dart`  
2. Call `result.safetyColor(context)` — not `result.safe == true ? Colors.green : ...`

---

## 5 · State Management Explanation

**Pattern:** `ChangeNotifier` + `Provider`

- `Consumer<T>` / `context.watch<T>()` in views subscribe to controller changes.
- Controllers call `notifyListeners()` after every state mutation.
- All 5 controllers are registered as `ChangeNotifierProvider` at the root (`main.dart`).

**Current limitation:** All providers init at app startup. This is fine for MVP but wastes memory if most screens are never visited. Migrate to lazy providers (or per-route scoping with `go_router`) if the app grows.

---

## 6 · Persistence Strategy

| Data Type | Storage | Access Point |
|---|---|---|
| Auth session (userId, token) | `SharedPreferences` | `LocalStorageService.saveAuthSession()` |
| User profile | `SharedPreferences` (JSON-encoded list) | `LocalStorageService.saveUser()` / `getUser()` |
| Scan history | `SharedPreferences` (JSON-encoded list) | `LocalStorageService.saveScanHistory()` |
| Reports | `SharedPreferences` (JSON-encoded list) | `LocalStorageService.saveReports()` |
| Settings | `SharedPreferences` (key-value) | `SettingsController` (directly) |
| Profile image | App Documents directory (file) | `LocalStorageService.saveProfileImage()` |
| Local URL blacklist | `SharedPreferences` | `ScanService` (internally) |

**Key:** `SharedPreferences` is used for all structured data via `setStringList` with JSON-encoded entries. This works for MVP scale. When the data volume grows or relational queries are needed, migrate to `drift` (SQLite ORM).

---

## 7 · How Authentication Currently Works (Mock Flow)

```
User taps Login
      │
AuthController.login(email, password)
      │
   [1] Validate inputs (empty check, password length)
      │
   [2] Future.delayed(2 seconds)  ← MOCK network delay
      │
   [3] storageService.getUserByEmail(email)
      │      ├── found → reuse existing userId  ← userId persistence fix
      │      └── not found → generate new userId
      │
   [4] Create UserModel with resolved userId
      │
   [5] storageService.saveAuthSession(userId, 'mock_token_...')
      │
   [6] storageService.saveUser(user)
      │
   [7] _isAuthenticated = true → notifyListeners()
      │
MaterialApp.home rebuilds → HomeScreen shown
```

**There is no real backend.** The token is a mock string. Password is never verified against storage — any 6+ character password succeeds.

### userId Persistence (the bug-fix)

**Before:** every `login()` call created `'user_${DateTime.now().millisecondsSinceEpoch}'` — a brand-new ID. All previous history was orphaned.

**After:** `getUserByEmail(email)` checks local storage. If the email was seen before, the **same userId is reused**. Scan history and profile data persist across logout/login cycles.

---

## 8 · Future Backend Integration Notes

### Where to plug in the real API

| Controller / Service | Mock to Replace | Real Implementation |
|---|---|---|
| `AuthController.login()` | `Future.delayed(2s)` | `POST /auth/login` → parse JWT |
| `AuthController.register()` | `Future.delayed(2s)` | `POST /auth/register` |
| `AuthController.resetPassword()` | `Future.delayed(2s)` | `POST /auth/reset-password` |
| `ApiService.scanUrl()` | Random number simulation | `GET /scan?url=...` |
| `ApiService.submitReport()` | Commented-out HTTP call | Uncomment + wire real endpoint |
| `ReportController.submitReport()` | `Future.delayed(2s)` | Delegate to `ApiService.submitReport()` |

### Auth Token Handling

Currently `saveAuthSession()` stores a mock token string. When real JWT is introduced:
1. Store the JWT in `flutter_secure_storage` (not `SharedPreferences`) for security.
2. Add a `dio` interceptor that attaches `Authorization: Bearer <token>` to all API requests.
3. Add token refresh logic if the API uses expiring JWTs.

### User Sync

`ProfileController._loadUserData()` currently loads from local storage only.
When real auth is wired:
1. After login, call `GET /users/me` with the JWT.
2. Map the response to `UserModel`.
3. Persist it via `LocalStorageService.saveUser()` for offline availability.

---

## 9 · Architectural Guardrails

> These rules **must not** be violated. They are the result of deliberate architectural decisions and protect long-term maintainability.

### 🚫 NEVER do these things:

| Rule | Reason |
|---|---|
| **Do not import `flutter/material.dart` (or any Flutter package) inside `lib/models/`** | Models are pure domain objects. Flutter coupling kills testability and portability. |
| **Do not call `SharedPreferences.getInstance()` directly from controllers** | All persistence must go through `LocalStorageService`. Multiple direct callers lead to silent key conflicts. |
| **Do not generate a new `userId` in `login()` without first checking local storage** | Breaks scan history persistence. Always call `getUserByEmail()` first. |
| **Do not use `if (!boolNullable)` without null checks** | `showDialog` returns `bool?`. Always use `if (value != true)` pattern. |
| **Do not add service instantiation inside controller class bodies** | Services must be injected via constructor. This is required for testability. |
| **Do not add new controllers to `MultiProvider` without a shared service instance** | Pass the shared `storageService` / `scanService` from `main.dart`. |

### ✅ Always do these things:

| Rule | Reason |
|---|---|
| **Add `// ← MOCK` comments on all hardcoded dummy data** | Makes them trivially searchable before backend integration. |
| **Route all auth session read/write through `LocalStorageService` session helpers** | `saveAuthSession`, `getAuthSession`, `clearAuthSession` are the single source of truth. |
| **Use `copyWith()` for all model mutations** | All models are immutable — never mutate a field directly. |
| **Document backend integration points with comments** | Every `Future.delayed` mock should have a `// Backend Integration Point` comment. |
| **Keep `widgets/scan_result_ui.dart` as the only place that maps `ScanResult` → `Color`** | Centralises color decisions; makes re-theming a one-file change. |

---

## 10 · Technical Debt Summary

| Category | Level | Notes |
|---|---|---|
| Architecture | 🟢 LOW | DI in place, layer boundaries enforced |
| Correctness | 🟡 MEDIUM | userId bug fixed; StatsCard data duplication remains |
| Testability | 🟠 MEDIUM-HIGH | DI in place but zero tests exist yet |
| Performance | 🟡 MEDIUM | All providers init eagerly; acceptable for MVP |
| Code quality | 🟡 MEDIUM | Mock data clearly marked; dead code remains in views |
| Security | 🔴 HIGH | Tokens in SharedPreferences; no HTTPS pinning |

---

## 11 · Migration Readiness for Future AI Agents

If you are an AI agent continuing this project, here is what you need to know:

1. **Mock flow is intentional.** Do not remove `Future.delayed` or hardcoded responses from `ApiService`. They will be replaced by real calls later.

2. **The codebase has no tests.** Before making structural changes, consider adding Dart unit tests for the controller layer. Services are now injectable, so mocking is straightforward.

3. **`ProfileController.user` still has a hardcoded fallback.** It is marked with `// ← MOCK`. Do not remove the fallback until real auth loads the user from the API.

4. **`blockedCount` in `StatsCard` shows the same value as `dangerousCount`.** This is a known bug in `views/main/main_screen.dart` line 372. Fix it by adding a real "blocked" counter to `ScanController`.

5. **All structural documentation is dual-homed:** this file (`README_ARCHITECTURE.md`) and the inline doc comments on every controller class.

6. **Search for `// ← MOCK` and `// Backend Integration Point`** to find all temporary stub code.

7. **`ScanService._checkLocalBlacklist()` and `_addToLocalBlacklist()`** read/write directly to `SharedPreferences`. This is an acceptable exception since it's an internal implementation detail of the service and does not bypass `LocalStorageService`'s public API.
