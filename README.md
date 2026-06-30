# GitMind

A Flutter app that lets you explore your GitHub repositories through AI-powered summaries and contextual chat — built with clean architecture, Cubit state management, and Gemini AI.

## Features

- **GitHub OAuth sign-in** via Firebase Auth
- **Real repository list** fetched from the GitHub API with search, filter, and sort
- **AI summaries** — one-tap Gemini-powered analysis of any repo (what it does, tech stack, strengths, weaknesses)
- **Repo-aware AI chat** — ask anything about a specific repo; Gemini answers with full context
- **Rate limit handling** — 429 responses trigger a 15-second countdown with auto-retry in both chat and summaries
- **SQLite persistence** — summaries cached locally; cleared on sign-out
- **Profile screen** — GitHub avatar, bio, stats, and owned repos
- **Settings** — model selection (Gemini 2.0 Flash / 2.5 Pro), auto-summarize toggle, cache control
- **Animated splash screen** and shimmer skeletons on all loading states
- **Dark / light theme** toggle
- Dev and Prod flavors with separate bundle IDs

## Screenshots

| Sign In | Repo List | Repo Detail | Chat |
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
| `flutter_secure_storage` | GitHub access token storage |
| `shared_preferences` | Settings persistence |
| `url_launcher` | Open GitHub profile in browser |
| `flutter_native_splash` | Animated splash screen |

## Architecture

Strict layered architecture: **presentation → domain → data**

```
lib/
├── core/
│   ├── di/             # get_it dependency registration
│   ├── error/          # AppException sealed class (RateLimitException, ServerException, …)
│   ├── result/         # ApiResult<T> — ApiSuccess / ApiFailure / ApiRateLimit
│   ├── theme/          # AppColors, ThemeCubit
│   └── widgets/        # TopBar, ShimmerBox, StatusPill
│
└── features/
    ├── chat/           # Gemini chat with repo context, cooldown, 429 countdown
    ├── profile/        # GitHub user profile, avatar, stats, owned repos
    ├── repo_detail/    # Repo header, AI summary, regenerate, rate-limit banner
    ├── repo_list/      # GitHub repos, search/filter/sort, Gemini summary service
    ├── settings/       # Model picker, auto-summarize, cache, persistence
    ├── sign_in/        # Firebase GitHub OAuth, token storage
    └── splash/         # Animated splash with logo
```

Each feature follows:
```
data/
  datasources/    # API calls, SQLite, secure storage
  models/         # JSON ↔ entity mapping
  repositories/   # Impl — catches exceptions, returns ApiResult
domain/
  entities/       # Pure Dart — no Flutter imports
  repositories/   # Abstract interface
  usecases/       # Single-purpose use cases
presentation/
  cubit/          # State logic, Timer-based countdowns
  screens/        # UI — observes state, zero business logic
  widgets/        # Reusable screen-level widgets, skeletons
```

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
git clone https://github.com/engmostafasoliman/Chaty_AI_-Agent.git
cd Chaty_AI_-Agent
flutter pub get
```

### Run

```bash
# Dev — simulator / device
flutter run \
  --flavor dev \
  --target lib/main_dev.dart \
  --dart-define=GEMINI_API_KEY=your_key_here

# Prod
flutter run \
  --flavor prod \
  --target lib/main_prod.dart \
  --dart-define=GEMINI_API_KEY=your_key_here
```

> Never commit your API key. Pass it via `--dart-define` at runtime only.

## Testing

```bash
flutter test
```

Covers domain entities, use cases, repository implementations, and cubits across:
- `SendMessageCubit` — all states, cooldown, rate-limit countdown
- `RepoDetailCubit` — summary flow, 429 handling
- `SettingsCubit` — persistence, defaults
- `SettingsEntity` — copyWith, defaults
- `ClearSummariesUseCase`

## AI Models

Selectable in Settings:

| Model | Use case |
|---|---|
| `gemini-2.0-flash` | Default — fast, cost-efficient |
| `gemini-2.5-pro` | Deeper analysis, slower |
