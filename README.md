# GitMind

A Flutter app that lets you explore your GitHub repositories through AI-powered summaries and contextual chat — built with clean architecture, Cubit state management, and Gemini AI [Video](https://www.linkedin.com/feed/update/urn:li:activity:7478356838674247681/).

## Features

- **GitHub OAuth sign-in** via Firebase Auth with session persistence across app restarts
- **Real repository list** fetched from the GitHub API with search, filter, and sort
- **AI summaries** — one-tap Gemini-powered analysis of any repo (what it does, tech stack, strengths, weaknesses)
- **GitMind AI chat** — repo-aware assistant named GitMind; ask anything about a specific repo and get context-aware answers
- **Debounce & throttle** — 300ms debounce on search, 10s per-repo throttle on Gemini calls to prevent redundant API usage
- **Token optimization** — summary prompt ~50% smaller (1500-char README cap, compact format); chat history capped at last 10 visible messages
- **Rate limit handling** — 429 responses trigger a 15-second countdown with auto-retry in both chat and summaries
- **SQLite persistence** — summaries cached locally; cleared on sign-out
- **Profile screen** — real GitHub avatar, bio, follower count, and owned repos fetched live from the GitHub API
- **Settings** — model selection, auto-summarize toggle, cache control
- **Animated splash screen** and shimmer skeletons on all loading states
- **Dark / light theme** toggle
- **Firebase App Distribution** — GitHub Actions workflow for distributing dev builds to testers
- Dev and Prod flavors with separate bundle IDs

## Screenshots

| Sign In | Repo List | Repo Detail | GitMind Chat |
|---|---|---|---|
| GitHub OAuth | Search & filter | AI summary | Context-aware Q&A |

## Tech Stack

| Package | Purpose |
|---|---|
| `flutter_bloc` | State management (Cubit/sealed states) |
| `get_it` | Dependency injection |
| `firebase_auth` | GitHub OAuth |
| `http` | Network requests |
| `sqflite` | Local summary cache |
| `flutter_secure_storage` | GitHub access token + session persistence |
| `shared_preferences` | Settings persistence |
| `url_launcher` | Open GitHub profile in browser |
| `flutter_native_splash` | Animated splash screen |

## Architecture

Strict layered architecture: **presentation → domain → data**

```
lib/
├── core/
│   ├── analytics/      # AnalyticsService — Firebase event logging
│   ├── config/         # AppConfig (flavors, API keys), dev_fixtures
│   ├── constants/      # Language colour map
│   ├── di/             # get_it dependency registration
│   ├── error/          # AppException sealed class (RateLimitException, ServerException, …)
│   ├── result/         # ApiResult<T> — ApiSuccess / ApiFailure / ApiRateLimit
│   ├── theme/          # AppColors, ThemeCubit
│   └── widgets/        # TopBar, ShimmerBox, StatusPill
│
└── features/
    ├── chat/           # GitMind AI chat — repo context, 5s cooldown, 429 countdown
    ├── profile/        # Real GitHub user profile fetched via /user API
    ├── repo_detail/    # Repo header, AI summary, re-summarize, rate-limit banner
    ├── repo_list/      # GitHub repos, search/filter/sort, debounce, Gemini throttle
    ├── settings/       # Model picker, auto-summarize, cache, accent colour
    ├── sign_in/        # Firebase GitHub OAuth, token storage, session persistence
    └── splash/         # Animated splash with session check
```

Each feature follows:
```
data/
  datasources/    # API calls, SQLite, secure storage — one responsibility per class
  models/         # JSON ↔ entity mapping
  repositories/   # Impl — catches exceptions, maps to ApiResult
domain/
  entities/       # Pure Dart — zero Flutter imports
  repositories/   # Abstract interface
  usecases/       # Single-purpose, one public method each
presentation/
  cubit/          # State logic, Timer-based countdowns, debounce
  screens/        # UI — observes state, zero business logic
  widgets/        # Reusable screen-level widgets, skeletons
```

### Key design decisions

| Decision | Detail |
|---|---|
| **Datasource split** | `GitHubRepoHttpSource` (pure HTTP) + `RepoSummaryDataSource` (cache + throttle + Gemini + SQLite); orchestrated by a thin `GitHubRepoDataSource` |
| **No cross-feature domain imports** | `GetRepoDetailUseCase` and `GenerateSummaryUseCase` live in `repo_detail/domain/` — only used there |
| **Constructor-injected analytics** | `AnalyticsService` passed via constructor in all cubits; no `getIt` calls inside logic |
| **Factory cubits** | All cubits registered as `registerFactory` — fresh instance per screen, no stale state |
| **Reactive model selection** | Chat reads `geminiModel` from `SettingsRepository` at each send call — settings change takes effect immediately |
| **Real profile data** | `ProfileCubit` fetches user from `GET /user` via `GetProfileUseCase`; no hardcoded mock in production |

## Error Handling

| Scenario | Handling |
|---|---|
| 429 rate limit (chat) | Inline yellow card with 15s countdown + auto-retry |
| 429 rate limit (summary) | Yellow banner with countdown + "Now" button |
| Network / server error | Inline red error card with Retry button |
| Sign-in failure | SnackBar with message |
| Avatar load failure | Gradient initials fallback |

## Flavors

| | Dev | Prod |
|---|---|---|
| Bundle ID (Android) | `com.codemind.chatyaiagent.dev` | `com.codemind.chatyaiagent` |
| Bundle ID (iOS) | `com.codemind.chatyaiagent.dev` | `com.codemind.chatyaiagent` |
| App name | GitMind Dev | GitMind |

## Getting Started

### Prerequisites

- Flutter SDK `^3.10.4`
- A [Gemini API key](https://aistudio.google.com/app/apikey)
- Firebase project with GitHub OAuth configured

### Setup

```bash
git clone https://github.com/engmostafasoliman/GitMind.git
cd GitMind
flutter pub get
```

Create a `.env` file in the project root (gitignored — never commit this):

```env
GEMINI_API_KEY=your_gemini_api_key
GITHUB_CLIENT_ID=your_github_oauth_client_id
GITHUB_CLIENT_SECRET=your_github_oauth_client_secret
```

### Run

```bash
# Dev — simulator / device
flutter run \
  --flavor dev \
  --target lib/main_dev.dart \
  --dart-define=GEMINI_API_KEY=$(grep GEMINI_API_KEY .env | cut -d= -f2) \
  --dart-define=GITHUB_CLIENT_ID=$(grep GITHUB_CLIENT_ID .env | cut -d= -f2) \
  --dart-define=GITHUB_CLIENT_SECRET=$(grep GITHUB_CLIENT_SECRET .env | cut -d= -f2)

# Prod
flutter run \
  --flavor prod \
  --target lib/main_prod.dart \
  --dart-define=GEMINI_API_KEY=$(grep GEMINI_API_KEY .env | cut -d= -f2) \
  --dart-define=GITHUB_CLIENT_ID=$(grep GITHUB_CLIENT_ID .env | cut -d= -f2) \
  --dart-define=GITHUB_CLIENT_SECRET=$(grep GITHUB_CLIENT_SECRET .env | cut -d= -f2)
```

> Never commit your API keys. Pass them via `--dart-define` at runtime only.

## CI / Distribution

A GitHub Actions workflow (`.github/workflows/distribute.yml`) builds and distributes the **dev** flavor APK to Firebase App Distribution testers on manual trigger (`workflow_dispatch`).

Required GitHub Secrets:

| Secret | Description |
|---|---|
| `GEMINI_API_KEY` | Gemini API key |
| `GITHUB_CLIENT_ID` | GitHub OAuth app client ID |
| `GITHUB_CLIENT_SECRET` | GitHub OAuth app client secret |
| `FIREBASE_APP_ID` | Firebase App ID for the dev flavor |
| `FIREBASE_TOKEN` | Firebase CLI token |
| `FIREBASE_TESTER_GROUPS` | Tester group name (e.g. `tester`) |

## Testing

### Automated

```bash
flutter test
```

**90 tests — all passing.** Coverage across:

| File | What's tested |
|---|---|
| `SendMessageCubit` | All states, cooldown, rate-limit countdown, GitMind persona init, empty/whitespace guard |
| `GeminiChatRepositoryImpl` | Success, all error types, history trimming, reactive model selection from settings |
| `RepoListCubit` | Load success/failure, 300ms debounce on search, rapid-call cancellation, filter, sort, clearFilters |
| `AuthRepositoryImpl` | `getPersistedUser()` session persistence — returns user when Firebase session exists, null when not, clears on sign-out |
| `ProfileRepositoryImpl` | Success with real GitHub user, missing token, unauthorized, generic HTTP error |
| `GetProfileUseCase` | Delegates to repository |
| `ProfileCubit` | Load with real user + owned repo filtering, profile failure, repos failure |
| `AnalyticsService` | `regenerated` param is always `int` (0/1), never `bool`; `logRepoViewed`, `logModelChanged` params |
| `SettingsCubit` | Load, all setters, accent propagation to ThemeCubit, clearSummaries delegation |
| `SettingsEntity` | `copyWith`, defaults, field preservation |
| `ClearSummariesUseCase` | Delegates to repository |
| `SendMessageUseCase` | Delegates to repository |
| `ChatMessageModel` | JSON serialization |

### Manual / Device

| Scenario | Device |
|---|---|
| Sign-in, repo list, AI summary, GitMind chat | iPhone 17 Pro Max simulator |
| Sign-in, repo list, AI summary, GitMind chat | Realme RMX3771 (Android, real device) |
| Firebase App Distribution install + launch | Realme RMX3771 (via Firebase Tester app) |
| Session persistence after app termination | Both platforms |
| Re-summarize button visibility above FAB | Both platforms |
| Debounce on search, throttle on Gemini calls | Both platforms |

## AI Models

Selectable in Settings:

| Model | Use case |
|---|---|
| `gemini-flash-latest` | Default — fast, cost-efficient, always up to date |
| `gemini-2.0-flash` | Stable pinned version |
| `gemini-2.5-pro` | Deeper analysis, slower |
