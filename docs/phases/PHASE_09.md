# Phase 09 — Notifications

> **Status**: Not Started | **Completion**: 0% | **Parent**: [`ROADMAP.md`](../ROADMAP.md)

---

## Phase Overview

| Field | Value |
|-------|-------|
| **Phase Number** | 09 |
| **Phase Name** | Notifications |
| **Objective** | Integrate Firebase Cloud Messaging (FCM) for push notifications. Handle foreground and background notification display. Build a notification history screen with read/unread state and tap-to-navigate to event details. Display unread badge count on the Home screen bell icon. |
| **Scope** | `lib/features/notifications/`, `lib/core/network/` (FCM setup), `lib/features/home/` (badge icon update), Android `AndroidManifest.xml`, iOS `Info.plist` |
| **Expected Deliverables** | FCM device token registered on login, push notifications received in foreground (local notification + sound), notification history screen with read/unread indicators, tap notification → navigate to event details, unread badge on bell icon |
| **Dependencies** | Phase 07 (backend integration — FCM token registration requires auth and backend endpoint) |
| **Assigned Module** | Mobile |

---

## Task Checklist

| # | Status | Task | Module | Priority | Dependencies |
|---|:------:|------|:------:|:--------:|:------------:|
| 1 | Not Started | Configure Firebase project and add `firebase_core` + `firebase_messaging` + `flutter_local_notifications` to `pubspec.yaml` | Mobile | High | Phase 07 |
| 2 | Not Started | Configure Android: add `google-services.json` to `android/app/`, update `AndroidManifest.xml` for FCM permissions and notification channels | Mobile | High | 1 |
| 3 | Not Started | Configure iOS: add `GoogleService-Info.plist` to `ios/Runner/`, enable push notification capability in Xcode | Mobile | High | 1 |
| 4 | Not Started | Initialize Firebase in `lib/main.dart` (`Firebase.initializeApp()`) before `runApp()` | Mobile | High | 1 |
| 5 | Not Started | Create `lib/features/notifications/data/notification_service.dart` — request notification permissions, configure local notification channels, handle FCM token retrieval | Mobile | High | 1 |
| 6 | Not Started | Register FCM device token on login: call `POST /fcm/token` with the device token and JWT | Mobile | High | 5, Phase 07 |
| 7 | Not Started | Create FCM foreground message handler: convert incoming FCM message to local notification display (using `flutter_local_notifications`) | Mobile | High | 5 |
| 8 | Not Started | Create FCM background message handler (top-level function) — for background/terminated notification display | Mobile | High | 5 |
| 9 | Not Started | Create `lib/features/notifications/models/notification_model.dart` — Freezed model for notification (id, title, body, eventId, timestamp, isRead) | Mobile | High | 1 |
| 10 | Not Started | Create `lib/features/notifications/providers/notification_provider.dart` — manages notification list state and unread count | Mobile | High | 9 |
| 11 | Not Started | Create `lib/features/notifications/presentation/widgets/notification_tile.dart` — notification list item with title, body, timestamp, read/unread indicator | Mobile | Medium | 10 |
| 12 | Not Started | Create `lib/features/notifications/presentation/screens/notifications_screen.dart` — list of notifications, "Mark All Read" action | Mobile | High | 10, 11 |
| 13 | Not Started | Add route for Notifications screen (`/notifications`) in GoRouter, accessible via bell icon on Home app bar | Mobile | High | 12 |
| 14 | Not Started | Implement tap-to-navigate: tapping a notification navigates to `/events/:id` for the associated event | Mobile | High | 12, 13 |
| 15 | Not Started | Add unread badge to Home screen bell icon — show count from `notificationProvider.unreadCount` | Mobile | High | 10 |
| 16 | Not Started | Handle notification tap when app is terminated: extract event ID from notification payload → navigate to event details on app launch | Mobile | High | 8, 14 |
| 17 | Not Started | Test end-to-end: backend sends test notification → app receives and displays → tap → navigates to correct event | Mobile | High | All above |

---

## Completed Work

> No work has been completed in this phase yet.

| Date | Completed | Files Modified | Notes |
|------|-----------|----------------|-------|
| — | — | — | — |

---

## Current Work

> Nothing is currently being worked on.

---

## Remaining Work

All tasks remain. The **critical path** is:

1. Firebase setup + dependencies (tasks 1–4) → notification service (task 5)
2. FCM handlers (tasks 7–8) → token registration (task 6)
3. Notification model + provider (tasks 9–10) → UI (tasks 11–12)
4. Navigation + badge (tasks 13–15) → terminated state handling (task 16)
5. End-to-end test (task 17)

---

## Blockers

| Blocker | Impact | Since | Resolution |
|---------|--------|-------|------------|
| **Firebase project not configured** | ALL tasks blocked | — | Create Firebase project, download config files, enable Cloud Messaging. |
| **Backend FCM endpoint not implemented** | Token registration fails | — | Coordinate with Member 2 to implement `POST /fcm/token`. |
| **iOS push cert / APNs not configured** | Notifications fail on iOS | — | Configure APNs key/certificate in Firebase console + Apple Developer portal. |

---

## Decisions Made

| Decision | Rationale | Date |
|----------|-----------|------|
| — | — | — |

---

## Notes For Next Agent

> ⚠️ **Read this section before starting work. It contains everything you need to continue without rereading the repository.**

### Context
- Phase 07 must be complete. The app is connected to the real backend with auth working.
- Firebase Cloud Messaging requires both Firebase project configuration AND platform-specific setup.
- Notifications work differently in three app states: **foreground** (app open), **background** (app minimized), and **terminated** (app killed).

### What Was Done
- Nothing yet.

### What Remains
- All 17 tasks. The phase is blocked until Firebase is configured.

### Suggested Next Steps
1. **Do NOT start this phase** until Firebase is set up (project created, config files downloaded).
2. Add Firebase dependencies (task 1) → initialize in main.dart (task 4).
3. Configure Android (task 2) and iOS (task 3) — follow Firebase docs exactly.
4. Build the notification service: permissions, local notifications, FCM token handling (task 5).
5. Register FCM token on login (task 6).
6. Build foreground + background message handlers (tasks 7–8).
7. Create notification model, provider, UI (tasks 9–12).
8. Wire navigation and badge (tasks 13–16).
9. End-to-end test with backend-sent notification (task 17).

### Warnings
- The **background message handler must be a top-level function** (not inside a class) — this is a Firebase requirement.
- iOS push notifications **require physical device testing** — they do not work on the iOS simulator.
- Android 13+ requires **runtime permission request** for notifications — `flutter_local_notifications` handles this, but test it carefully.
- `firebase_messaging` `onBackgroundMessage` runs in a separate Dart isolate — it cannot access `SharedPreferences`, `ProviderContainer`, or any app state. Only basic Dart and the message payload are available.
- The notification payload must include an `eventId` field so the app can navigate to the correct event details page when tapped.

### Assumptions
- Backend sends notifications with a data payload containing `{ "eventId": "...", "title": "...", "body": "..." }`.
- The backend supports storing and optionally retrieving notification history. If not, notifications are stored locally only.
- Unread count is tracked locally (not server-side).
- Sound and vibration defaults are platform-appropriate.

### Useful Context
- See [`ARCHITECTURE.md`](../ARCHITECTURE.md) "Notification Architecture" for the flow diagram.
- See [`FEATURES_AND_FLOWS.md`](../FEATURES_AND_FLOWS.md) "Notifications Screen" section for the full spec.
- See [`PROJECT_OVERVIEW.md`](../PROJECT_OVERVIEW.md) for the notification types table.
