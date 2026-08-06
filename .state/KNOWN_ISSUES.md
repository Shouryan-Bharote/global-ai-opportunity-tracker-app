# Known Issues

> **Updated by agents when blockers are discovered or resolved.**

## Active Blockers

| Date Discovered | Phase | Blocker Description | Suggested Resolution | Status |
|-----------------|:-----:|---------------------|----------------------|--------|
| —               | —     | —                   | —                    | —      |

## Resolved Issues

| Date Discovered | Date Resolved | Issue | Resolution |
|-----------------|---------------|-------|------------|
| 2026-07-13      | 2026-07-13    | `flutter pub get` fails due to lack of symlink support on Windows. | The user enabled Developer Mode in Windows settings (`start ms-settings:developers`) to allow symlink creation. |
| 2026-07-16      | 2026-07-16    | Android build fails on Windows with "this and base files have different roots" Kotlin incremental cache conflict when project is on D: drive and Pub cache is on C: drive. | Disabled Kotlin incremental compilation by adding `kotlin.incremental=false` to `android/gradle.properties`. |
| 2026-07-16      | 2026-07-16    | Android build fails with "CheckAarMetadataWorkAction" because package updates require newer Android 36 SDK. | Upgraded `compileSdk` to 36 in both the main application (`android/app/build.gradle.kts`) and subproject configurations (`android/build.gradle.kts`). |
