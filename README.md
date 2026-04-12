# BillMate

BillMate is a Flutter app for monthly bill reminders, split-bill tracking, and lightweight personal finance coordination.

It is built with Flutter, Supabase, and OneSignal, and is organized using a sprint-based workflow for clear branch ownership and delivery.

## What BillMate Does

- Email/password authentication with Supabase Auth
- Google OAuth sign-in with Supabase Auth
- Monthly bill management and future split-bill features
- Supabase-backed data sync and user session handling
- Foundation for local reminders and OneSignal push flows

## Tech Stack

- Flutter
- Supabase
- OneSignal
- Flutter Dotenv
- Material 3

## Branch Overview

These are the branches currently present in this repository:

| Branch                           | Purpose                                     |
| -------------------------------- | ------------------------------------------- |
| `main`                           | Production-ready history                    |
| `develop`                        | Integration branch across sprints           |
| `sprint/s1-foundation`           | Sprint 1 foundation branch                  |
| `sprint/s2-bills`                | Sprint 2 bills branch                       |
| `sprint/s3-notification-offline` | Sprint 3 notifications and offline branch   |
| `sprint/s4-recap-split`          | Sprint 4 recap and split bill branch        |
| `feat/s1-supabase-startup`       | Sprint 1 Supabase startup feature branch    |
| `feat/s1-auth-email-password`    | Sprint 1 email/password auth feature branch |

Working branches should always be created from the active sprint branch, not directly from `main`.

## Setup

1. Install dependencies:

```bash
flutter pub get
```

2. Create your local `.env` file from `.env.example` and fill in:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `ONESIGNAL_APP_ID`

3. Run the app:

```bash
flutter run
```

## Environment Notes

- If Supabase config is missing, the app shows a safe fallback screen.
- OAuth redirects use the custom callback scheme configured for Supabase sign-in.

## Contributing Flow

- Pick the active sprint branch first.
- Create a working branch using the agreed naming pattern.
- Finish a small scope, then commit and push immediately to the agreed working branch.
- Open a PR to the target sprint branch and keep CI green.

## License

BillMate is released under the MIT License. See [LICENSE](LICENSE) for details.
