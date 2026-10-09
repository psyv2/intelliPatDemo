# Learning Dashboard (iOS)

A small SwiftUI learning-dashboard app: login → course list → course detail with
lesson completion, progress tracking, and offline support.

Built with Swift / SwiftUI, targeting iOS 26, using the `@Observable` Observation
framework and the Swift Testing framework.


## Project structure

```
Core/          ViewState, SessionStore, AppEnvironment (composition root)
Models/        Course, Lesson, AuthToken (domain)
Networking/    CourseAPI / AuthAPI protocols + mock impls, DTO + mapping
Persistence/   CourseStore + SwiftDataCourseStore, PersistenceModels, TokenStore (Keychain)
Repositories/  CourseRepository, AuthRepository
ViewModels/    Login / CourseList / CourseDetail
Views/         RootView, LoginView, CourseListView, CourseDetailView
Resources/     courses.json (mock API payload)
```

---

## README answers

### 1. Architecture

**MVVM + Repository.** The flow is `View → ViewModel → Repository → (API + Local
Store)`. I chose it because it cleanly separates the four concerns the brief cares
about:

- **Views** are dumb and render a single `ViewState` enum (`loading / loaded /
  empty / failed`) — no business logic, no conflicting boolean flags.
- **ViewModels** (`@Observable`, `@MainActor`) own presentation state only.
- **The `CourseRepository` is the single source of truth.** It owns the
  API-vs-cache decision and the lesson-completion mutations, so that policy lives
  in exactly one place.
- **Everything is behind a protocol** (`CourseAPI`, `AuthAPI`, `CourseStore`,
  `TokenStore`), wired together in one composition root (`AppEnvironment`).
  Swapping the mock API for a real `URLSession` client is a one-line change and
  nothing else moves. This is also what makes the repository trivially testable.

**Progress is derived, never stored.** A course's progress is computed from its
lessons (`completed / total`). Keeping one source of truth means the progress bar
and the lesson checklist can never disagree.

### 2. Offline support

The repository implements a **cache-with-network-fallback** policy:

- On a successful fetch it maps the API DTOs to domain models, **merges in any
  locally-completed lessons** (so a refresh never wipes the learner's progress),
  persists the result, and returns it.
- If the network call fails, it returns the last-known-good data from the local
  cache and flags `isFromCache` so the UI can show an "offline" banner. The error
  only surfaces if there is no cache at all.

Storage is **SwiftData** (`SwiftDataCourseStore`). The `@Model` types
(`CourseModel` / `LessonModel`) are kept separate from the domain structs so
persistence stays an implementation detail. The store sits behind the
`CourseStore` protocol, so the repository is unaware of the storage technology
and it can be swapped without touching other layers. Lesson completions are
written through the same store immediately, so they survive relaunch and offline.

### 3. Security — where auth tokens live

Tokens are stored in the **Keychain** (`KeychainTokenStore`), with
`kSecAttrAccessibleAfterFirstUnlock`. Never in `UserDefaults` or plist files —
those are unencrypted, included in device/iCloud backups, and readable on a
jailbroken device. In a full production app I'd additionally:

- Keep only a short-lived **access token** in memory and a **refresh token** in
  the Keychain, refreshing transparently on 401s.
- Pin TLS / use certificate pinning for the auth host.
- Gate the Keychain item behind biometrics for sensitive actions where warranted.

### 4. Scale — 1M users + hundreds of courses

1. **Paginate the course API** (cursor-based) and lazy-load — never fetch the full
   catalogue; render with a lazy list.
2. **Index the SwiftData store** and use batched/paged fetches, caching only
   the user's enrolled/recent courses rather than the entire catalogue.
3. **Delta sync + ETag / `If-None-Match`** so refreshes transfer only what
   changed, plus a proper **sync queue** for completion events (offline writes
   replayed when back online, idempotent on the server).
4. **CDN + image caching** for thumbnails/media, and HTTP caching headers.
5. **Observability**: crash reporting, structured logging, performance metrics,
   and feature flags for safe rollout — plus server-side rate limiting.
6. **UIKit**: use UIkit where perfomance matters most; coz there are low level controls uikit provides which swiftUI doesnt like reusecell etc, there is no direct alternative of uicollectionview and uitableview
The architecture ports almost 1:1 because the layering is platform-agnostic:

- **UI:** Jetpack Compose instead of SwiftUI; the same `ViewState` sealed class
  drives a single composable per screen.
- **ViewModel:** Android `ViewModel` exposing a `StateFlow<ViewState>` (the direct
  analogue of `@Observable`), with `viewModelScope` coroutines replacing
  `async/await` `Task`s.
- **Repository:** identical interface and offline-fallback policy, as a Kotlin
  `interface` + implementation.
- **API:** Retrofit + OkHttp behind the repository's interface.
- **Local store:** Room (SQLite) in place of the file cache / SwiftData.
- **Secure storage:** Android Keystore + EncryptedSharedPreferences in place of
  the Keychain.
- **DI:** Hilt as the composition root instead of `AppEnvironment`.

## Testing

`intellipatAppTests/CourseRepositoryTests.swift` covers the highest-value business
logic using in-memory fakes:

- Progress is correctly derived from completed lessons.
- The repository **falls back to cache** when the API fails, and **propagates the
  error** when there's no cache.
- A refresh **preserves locally-completed lessons** (the merge logic).

Run with `⌘U` or the test navigator.
