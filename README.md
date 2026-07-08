# News & Weather Hub

Flutter app combining live weather (Open-Meteo) and news headlines (NewsAPI),
built with **Riverpod** for state management.

## 1. Setup

### Prerequisites
- Flutter 3.22+ (Dart 3.3+)
- A free API key from https://newsapi.org/register

### First run
This repo ships only the `lib/` and `test/` source — platform folders
(`android/`, `ios/`) are generated locally to keep the repo clean:

```bash
flutter create . --platforms=android,ios --org com.example
flutter pub get
```

### Add the NewsAPI key
Two supported options — pick one:

**Option A — .env file (used by `flutter_dotenv`)**
```bash
cp .env.example .env
# then edit .env and paste your real key:
# NEWS_API_KEY=xxxxxxxxxxxxxxxx
```
`.env` is git-ignored; only `.env.example` (placeholder) is committed.

**Option B — --dart-define**
```bash
flutter run --dart-define=NEWS_API_KEY=xxxxxxxxxxxxxxxx
```
If you use this option, read `NEWS_API_KEY` via
`String.fromEnvironment('NEWS_API_KEY')` instead of dotenv in
`lib/providers/core_providers.dart` (one-line swap, both are wired for
clarity in comments there).

### Permissions
Add to `android/app/src/main/AndroidManifest.xml` (inside `<manifest>`, above `<application>`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We use your location to show local weather.</string>
```

### Run
```bash
flutter run
```

### Run tests
```bash
flutter test
```

### Build APK
```bash
flutter build apk --release --dart-define=NEWS_API_KEY=xxxxxxxxxxxxxxxx
```
(omit `--dart-define` if you're using the `.env` file approach — just make
sure `.env` exists before building, since it's bundled as an asset).

---

## 2. Architecture Overview

```
lib/
  core/            # cross-cutting: constants, theme, network client, errors, utils
  data/
    models/        # plain Dart models + hand-written Hive TypeAdapters
    local/          # Hive data sources (cache, bookmarks, settings)
    repositories/    # networking + cache-fallback logic, own data layer per API
  providers/         # Riverpod providers: DI, weather, news, city search, bookmarks, settings
  features/
    dashboard/        # Screen 1: weather + forecast + news feed
    news_details/      # Screen 2
    bookmarks/          # Screen 3
    settings/            # Screen 4
    common/               # shared widgets (error/empty/offline states)
```

**Layering:** UI (ConsumerWidget) → Riverpod `StateNotifier` (state + intent
handling) → Repository (network + cache orchestration) → Dio / Hive.
No screen talks to Dio or Hive directly.

**State management:** `StateNotifierProvider` per feature (`weatherProvider`,
`newsProvider`, `citySearchProvider`, `bookmarksProvider`, `settingsProvider`).
Plain `Provider`s are used for DI (repositories, data sources, Dio instances)
so they're trivially swappable in tests.

**Networking:** each API has its own `Dio` instance and repository
(`WeatherRepository`, `NewsRepository`, `GeocodingRepository`) — no
all-in-one wrapper package. A shared `RetryInterceptor` retries timeouts,
connection errors, 5xx, and 429 up to twice with linear backoff before
surfacing a `Result.failure`.

**Persistence (Hive):**
- `weather_cache_box` — single key `"last"` → last successful weather payload + timestamp
- `news_cache_box` — single key `"last"` → last successful page-1 headlines + timestamp
- `bookmarks_box` — keyed by article URL → full `NewsArticle`
- `settings_box` — plain key/value: theme mode, default city name/lat/lon

Adapters are hand-written (not left as unexamined generated boilerplate):
each stores a plain `Map` so the schema is explicit and easy to version.

**Resilience:** every repository checks connectivity first; on failure it
falls back to the last cached response (weather, news page 1) and marks
`isFromCache = true` with a `cachedAt` timestamp, which the UI renders as an
"showing offline data from …" banner instead of a blank error screen.

---

## 3. Design Decisions Write-Up

1. What happens in your app if both the Weather and News APIs fail at the same time? Walk through it screen by screen.

Answer:

The app opens normally.
The Weather section shows an error message like "Failed to load weather. Please try again."
The News section also shows an error message like "Failed to load news."
If a Retry button is available, the user can tap it to fetch the data again.
The app does not crash, and users can still access features like bookmarks if they are stored locally.

2. Why did you choose your specific local persistence option (Hive/SQLite/Isar), and what would change if bookmarks needed to sync across a user's devices?

Answer:
I chose Hive because it is lightweight, fast, and easy to use in Flutter.
It is suitable for storing bookmarks locally without requiring SQL queries.
If bookmarks needed to sync across multiple devices, I would use a backend service like Firebase Firestore or my own API. Hive would be used only as a local cache, while the server would store and synchronize the user's bookmarks.

3. If you had one more day, what's the first thing you'd refactor or add, and why?

Answer:

I would improve error handling and add a Retry feature for failed API calls.
I would also add loading skeletons and caching to improve the user experience.
These changes would make the app more reliable and responsive for users.

---