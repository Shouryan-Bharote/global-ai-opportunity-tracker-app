# Graph Report - global-ai-opportunity-tracker-app  (2026-10-18)

## Corpus Check
- 137 files · ~64,994 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1618 nodes · 2089 edges · 114 communities (99 shown, 15 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 3 edges (avg confidence: 0.82)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `9035cb7c`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- event_collection.dart
- auth_provider.dart
- GeneratedPluginRegistrant.swift
- providers.dart
- SingleTickerProviderStateMixin
- ROADMAP.md
- secure_storage.dart
- app_spacing.dart
- Checklist: Phase Completion
- Project Configuration
- Mobile App Architecture
- Notes For Next Agent
- Web Entry Point
- MainActivity.kt
- Android App Icon
- profile_screen.dart
- 2. During Development
- Feature Specifications
- AppDelegate
- Component Library
- Module 1 — Mobile Application
- recommended_event_card.dart
- Phase 01 — Research & Design System
- iOS Launch Image
- app_router.dart
- app_colors.dart
- Phase 02 — Core Infrastructure
- event_details_screen.dart
- Phase 03 — Authentication
- StatelessWidget
- event_model.dart
- Phase 05 — Feature Development
- package:ai_nexus/core/theme/app_colors.dart
- isDarkModeProvider
- Phase 06 — Event Details
- Phase 08 — Offline Mode
- Phase 09 — Notifications
- explore_category_card.dart
- isar_service_native.dart
- VoidCallback
- Codebase Guide — Flutter Mobile Module
- upcoming_event_tile.dart
- animated_filter_chip.dart
- Rules: Agent Progress & Documentation
- manifest.json
- profile_header.dart
- Design System
- profile_repository.dart
- repository_providers.dart
- Phase 10 — Polish & Testing
- home_provider.dart
- explore_categories.dart
- event_card.dart
- splash_screen.dart
- popular_cities.dart
- result.dart
- user_model.dart
- home_screen.dart
- explore_search_bar.dart
- AI Event Tracker — Project Overview
- explore_results.dart
- category_chips.dart
- mock_auth_repository.dart
- profile_provider.dart
- bounceable.dart
- exploreCategoryProvider
- schedule_event_card.dart
- app_header.dart
- featured_event_card.dart
- custom_text_field.dart
- event_repository.dart
- authProvider
- Decision Categories
- App Fix List — Global AI Opportunity Tracker
- QueryBuilder
- mock_event_repository.dart
- package:flutter/material.dart
- Development Status
- Task Queue
- @freezed
- otp_input_field.dart
- package:ai_nexus/features/auth/models/user_model.dart
- env_config.dart
- explore_filter_chips.dart
- validators.dart
- main.dart
- Known Issues
- date_formatter.dart
- ai_nexus
- rules/graphify.md
- workflows/graphify.md
- LaunchImage.imageset/README.md
- flutter_export_environment.sh
- EventEntity
- EventEntityByIndex
- isar_service_stub.dart
- AI Nexus Flutter Project
- Flutter Framework
- dio_client.dart
- auth_interceptor.dart
- app_shadows.dart
- package:flutter_riverpod/flutter_riverpod.dart
- _ProfileScreenState
- location_provider.dart
- generated_plugin_registrant.cc
- explore_provider.dart
- events_provider.dart
- http_event_repository.dart
- schedule_screen.dart

## God Nodes (most connected - your core abstractions)
1. `eventsProvider` - 17 edges
2. `_HomeScreenState` - 13 edges
3. `Mobile App Architecture` - 13 edges
4. `authProvider` - 11 edges
5. `Checklist: Phase Completion` - 11 edges
6. `Module 1 — Mobile Application` - 11 edges
7. `AI Event Tracker — Master Roadmap` - 11 edges
8. `isDarkModeProvider` - 10 edges
9. `build` - 10 edges
10. `Feature Specifications` - 10 edges

## Surprising Connections (you probably didn't know these)
- `Android App Icon` --semantically_similar_to--> `iOS App Icon`  [INFERRED] [semantically similar]
  android/app/src/main/res/mipmap-hdpi/ic_launcher.png → ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
- `Web Entry Point` --references--> `Web Favicon`  [EXTRACTED]
  web/index.html → web/favicon.png
- `Web Entry Point` --references--> `Web PWA Icon`  [EXTRACTED]
  web/index.html → web/icons/Icon-192.png
- `Web Favicon` --semantically_similar_to--> `Web PWA Icon`  [INFERRED] [semantically similar]
  web/favicon.png → web/icons/Icon-192.png
- `Lint Configuration` --references--> `Flutter Lints Dev Dependency`  [EXTRACTED]
  analysis_options.yaml → pubspec.yaml

## Import Cycles
- None detected.

## Communities (114 total, 15 thin omitted)

### Community 0 - "event_collection.dart"
Cohesion: 0.01
Nodes (214): anyId, bytesCount, deleteAllByEventId, deleteAllByEventIdSync, deleteByEventId, deleteByEventIdSync, descriptionBetween, descriptionContains (+206 more)

### Community 1 - "auth_provider.dart"
Cohesion: 0.11
Nodes (17): bool get, AuthNotifier, build, copyWith, error, firebaseAuthProvider, isAuthenticated, isLoading (+9 more)

### Community 2 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.12
Nodes (15): device_info_plus, file_selector_macos, firebase_auth, firebase_core, firebase_messaging, flutter_secure_storage_darwin, FlutterMacOS, FlutterPluginRegistry (+7 more)

### Community 3 - "providers.dart"
Cohesion: 0.18
Nodes (10): IsarService, apiClientProvider, authInterceptor, authInterceptorProvider, dioClient, dioClientProvider, isarServiceProvider, secureStorageProvider (+2 more)

### Community 4 - "SingleTickerProviderStateMixin"
Cohesion: 0.23
Nodes (15): Bounceable, _BounceableState, AnimatedFilterChip, _AnimatedFilterChipState, _CategoryCardItem, _CategoryCardItemState, _ResultCardItem, _ResultCardItemState (+7 more)

### Community 5 - "ROADMAP.md"
Cohesion: 0.08
Nodes (29): Assumptions, Blockers, Context, Current Work, Decisions Made, Notes For Next Agent, Phase 04 — Navigation Shell, Phase Overview (+21 more)

### Community 6 - "secure_storage.dart"
Cohesion: 0.06
Nodes (29): dart:convert, FlutterSecureStorage, ApiConstants, baseUrl, connectTimeout, defaultPageSize, receiveTimeout, AppConstants (+21 more)

### Community 7 - "app_spacing.dart"
Cohesion: 0.07
Nodes (26): AppRadius, card, extraLarge, extraSmall, large, medium, pill, small (+18 more)

### Community 8 - "Checklist: Phase Completion"
Cohesion: 0.07
Nodes (27): 1. Point to a Single Feature, 2. Provide Context Files, 3. Follow Feature Isolation, 4. Testing Convention, AI Agent Guidelines, Checklist: Phase Completion, Commands Reference, Development Setup (+19 more)

### Community 9 - "Project Configuration"
Cohesion: 0.40
Nodes (6): Lint Configuration, Cupertino Icons Dependency, Dart SDK 3.12.2+, Flutter Lints Dev Dependency, Material Design Integration, Project Configuration

### Community 10 - "Mobile App Architecture"
Cohesion: 0.08
Nodes (25): Abstract Interface, Authentication Flow, Common Provider Patterns, Core Packages & Their Roles, Data Layer Architecture, Dependency Injection, Dependency Injection, Design System (Phase 1 Deliverable) (+17 more)

### Community 11 - "Notes For Next Agent"
Cohesion: 0.09
Nodes (23): Architecture Diagram, Assumptions, Blockers, Completed Work, Context, Current Work, Decisions Made, Key Files Reference (+15 more)

### Community 12 - "Web Entry Point"
Cohesion: 0.67
Nodes (4): Web Favicon, PWA Manifest, Web Entry Point, Web PWA Icon

### Community 15 - "profile_screen.dart"
Cohesion: 0.17
Nodes (11): _buildMenuItem, _buildStatItem, _buildVerticalDivider, createState, initState, _interests, package:ai_nexus/features/home/providers/home_provider.dart, package:ai_nexus/features/profile/providers/profile_provider.dart (+3 more)

### Community 16 - "2. During Development"
Cohesion: 0.10
Nodes (20): 1. Before Starting Work, 1. Update PHASE_XX.md, 2. During Development, 2. Update ROADMAP.md (Only If Phase Status Changed), 3. After Completing Work, 3. Update .state/ Files (If Changed), Add Newly Discovered Tasks, Mark Completed Items (+12 more)

### Community 17 - "Feature Specifications"
Cohesion: 0.11
Nodes (19): 1. Splash Screen, 2. Authentication (Sign In / Sign Up), 3. Home Screen, 4. Explore Screen, 5. Event Details Screen, 6. Schedule Screen, 7. Profile Screen, 8. Settings Screen (+11 more)

### Community 18 - "AppDelegate"
Cohesion: 0.11
Nodes (14): Any, Bool, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterSceneDelegate, AppDelegate (+6 more)

### Community 19 - "Component Library"
Cohesion: 0.11
Nodes (17): 1. Buttons, 2. Inputs, 3. Navigation, 4. Cards, 5. Chips & Tags, 6. Miscellaneous, `BottomNavigation`, `CategoryChip` / `FilterChip` (+9 more)

### Community 20 - "Module 1 — Mobile Application"
Cohesion: 0.11
Nodes (18): Architecture Summary, 🔐 Authentication, Core Features, 🌙 Dark Mode, Development Phases, Directory Overview, 🔍 Discovery, Interface Contract (+10 more)

### Community 21 - "recommended_event_card.dart"
Cohesion: 0.12
Nodes (16): build, _controller, createState, date, dispose, gradientColors, imageUrl, initState (+8 more)

### Community 22 - "Phase 01 — Research & Design System"
Cohesion: 0.12
Nodes (16): Assumptions, Blockers, Completed Work, Context, Current Work, Decisions Made, Notes For Next Agent, Phase 01 — Research & Design System (+8 more)

### Community 24 - "app_router.dart"
Cohesion: 0.09
Nodes (22): ChangeNotifier, GoRouter, isAuthenticated, notifier, _ref, _RouterNotifier, NavigatorState, Offset (+14 more)

### Community 25 - "app_colors.dart"
Cohesion: 0.08
Nodes (25): accentCyan, accentPink, accentPurple, AppColors, background, border, bottomNavigation, card (+17 more)

### Community 26 - "Phase 02 — Core Infrastructure"
Cohesion: 0.12
Nodes (16): Assumptions, Blockers, Completed Work, Context, Current Work, Decisions Made, Notes For Next Agent, Phase 02 — Core Infrastructure (+8 more)

### Community 27 - "event_details_screen.dart"
Cohesion: 0.07
Nodes (27): dart:ui, double get, build, _buildAboutTab, _buildDetailRow, _buildScheduleItem, _buildScheduleTab, _buildSpeakerTab (+19 more)

### Community 28 - "Phase 03 — Authentication"
Cohesion: 0.12
Nodes (16): Assumptions, Blockers, Completed Work, Context, Current Work, Decisions Made, Notes For Next Agent, Phase 03 — Authentication (+8 more)

### Community 29 - "StatelessWidget"
Cohesion: 0.09
Nodes (22): build, CustomNavBar, icon, isDarkMode, label, _NavBarItem, onDestinationSelected, onTap (+14 more)

### Community 30 - "event_model.dart"
Cohesion: 0.08
Nodes (24): description, endDate, hashCode, host, id, imageUrl, isBookmarked, isOnline (+16 more)

### Community 31 - "Phase 05 — Feature Development"
Cohesion: 0.12
Nodes (16): Blockers, Completed Work, Context, Current Work, Decisions Made, Key Architecture Files, Notes For Next Agent, Phase 05 — Feature Development (+8 more)

### Community 32 - "package:ai_nexus/core/theme/app_colors.dart"
Cohesion: 0.15
Nodes (22): dart:async, AuthState, build, createState, dispose, emailController, isLoading, build (+14 more)

### Community 33 - "isDarkModeProvider"
Cohesion: 0.13
Nodes (17): ConsumerWidget, App, build, isDarkModeProvider, routerProvider, AppShell, build, navigationShell (+9 more)

### Community 34 - "Phase 06 — Event Details"
Cohesion: 0.12
Nodes (16): Assumptions, Blockers, Completed Work, Context, Current Work, Decisions Made, Notes For Next Agent, Phase 06 — Event Details (+8 more)

### Community 35 - "Phase 08 — Offline Mode"
Cohesion: 0.12
Nodes (16): Assumptions, Blockers, Completed Work, Context, Current Work, Decisions Made, Notes For Next Agent, Phase 08 — Offline Mode (+8 more)

### Community 36 - "Phase 09 — Notifications"
Cohesion: 0.12
Nodes (16): Assumptions, Blockers, Completed Work, Context, Current Work, Decisions Made, Notes For Next Agent, Phase 09 — Notifications (+8 more)

### Community 37 - "explore_category_card.dart"
Cohesion: 0.12
Nodes (16): Color, backgroundColor, build, _controller, createState, dispose, icon, initState (+8 more)

### Community 38 - "isar_service_native.dart"
Cohesion: 0.12
Nodes (15): GetEventEntityCollection, dynamic get, Isar, db, init, _instance, IsarService, db (+7 more)

### Community 39 - "VoidCallback"
Cohesion: 0.15
Nodes (11): build, isLoading, onPressed, PrimaryButton, text, actionText, build, onActionTap (+3 more)

### Community 40 - "Codebase Guide — Flutter Mobile Module"
Cohesion: 0.13
Nodes (15): Branch Naming, Class Naming, Code Style Rules, Codebase Guide — Flutter Mobile Module, Commit Messages (Conventional Commits), Dart Coding Conventions, Directory Structure, Environment Configuration (+7 more)

### Community 41 - "upcoming_event_tile.dart"
Cohesion: 0.15
Nodes (13): build, createState, day, _isPressed, month, onTap, _onTapCancel, _onTapDown (+5 more)

### Community 42 - "animated_filter_chip.dart"
Cohesion: 0.15
Nodes (12): build, _controller, createState, dispose, initState, isSelected, label, onTap (+4 more)

### Community 43 - "Rules: Agent Progress & Documentation"
Cohesion: 0.17
Nodes (11): Documentation Priority, File Reference, Handoff checklist before ending:, Handoff Requirements, Inconsistency Detection, Phase Status Definitions, Prohibited Actions, Rule: Documentation truth > Code truth (+3 more)

### Community 44 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 45 - "profile_header.dart"
Cohesion: 0.22
Nodes (8): dart:io, _UserModel, build, _getInitials, onEditProfile, ProfileHeader, user, UserModel

### Community 46 - "Design System"
Cohesion: 0.22
Nodes (8): 1. Typography, 2. Color System, 3. Spacing Scale, 4. Radius, 5. Shadows, 6. Implementation Rules, Design System, Type Scale

### Community 47 - "profile_repository.dart"
Cohesion: 0.25
Nodes (8): FirebaseAuth, _auth, FirebaseProfileRepository, getUserProfile, _nameFromEmail, ProfileRepository, updateUserProfile, package:firebase_auth/firebase_auth.dart

### Community 48 - "repository_providers.dart"
Cohesion: 0.14
Nodes (14): ApiClient, _dioClient, DioClient, apiClientProvider, authInterceptor, authInterceptorProvider, dioClient, dioClientProvider (+6 more)

### Community 49 - "Phase 10 — Polish & Testing"
Cohesion: 0.12
Nodes (16): Assumptions, Blockers, Completed Work, Context, Current Work, Decisions Made, Notes For Next Agent, Phase 10 — Polish & Testing (+8 more)

### Community 50 - "home_provider.dart"
Cohesion: 0.11
Nodes (26): locationProvider, locationServiceProvider, allEvents, category, categoryFiltered, eventsAsyncValue, filteredEventsProvider, hasLocation (+18 more)

### Community 51 - "explore_categories.dart"
Cohesion: 0.10
Nodes (19): _categories, _CategoryConfig, _controller, createState, dispose, events, icon, iconBgColor (+11 more)

### Community 52 - "event_card.dart"
Cohesion: 0.22
Nodes (8): build, date, EventCard, host, id, imageUrl, onTap, title

### Community 53 - "splash_screen.dart"
Cohesion: 0.14
Nodes (15): ConsumerState, ConsumerStatefulWidget, ForgotPasswordScreen, _ForgotPasswordScreenState, build, _controller, createState, dispose (+7 more)

### Community 54 - "popular_cities.dart"
Cohesion: 0.33
Nodes (6): Animation, AnimationController, exploreCityProvider, build, _cities, PopularCities

### Community 55 - "result.dart"
Cohesion: 0.14
Nodes (16): _, data, error, hashCode, operator, _privateConstructorUsedError, toString, E (+8 more)

### Community 56 - "user_model.dart"
Cohesion: 0.13
Nodes (14): avatarUrl, email, hashCode, id, name, operator, _privateConstructorUsedError, toString (+6 more)

### Community 57 - "home_screen.dart"
Cohesion: 0.09
Nodes (22): _autoRefreshTimer, _countEventsForTopic, createState, _currentFeaturedPage, didChangeAppLifecycleState, dispose, _featuredPageController, _featuredTimer (+14 more)

### Community 58 - "explore_search_bar.dart"
Cohesion: 0.13
Nodes (18): FocusNode, exploreSearchQueryProvider, build, _clearSearch, createState, _debounce, dispose, ExploreSearchBar (+10 more)

### Community 59 - "AI Event Tracker — Project Overview"
Cohesion: 0.14
Nodes (14): AI Event Tracker — Project Overview, API Contract (Expected from Backend), Constraints & Assumptions, Data Sources (Planned), Expected Event Model, Future Work, Key Design Decisions, Overall Project Roadmap (+6 more)

### Community 60 - "explore_results.dart"
Cohesion: 0.12
Nodes (17): exploreFilteredEventsProvider, exploreResultsExpandedProvider, build, _controller, createState, day, dispose, ExploreResults (+9 more)

### Community 61 - "category_chips.dart"
Cohesion: 0.22
Nodes (8): build, categories, CategoryChipData, CategoryChips, icon, label, onCategorySelected, selectedCategory

### Community 62 - "mock_auth_repository.dart"
Cohesion: 0.29
Nodes (6): login, logout, MockAuthRepository, register, package:ai_nexus/core/mock/mock_user.dart, package:ai_nexus/core/utils/result.dart

### Community 63 - "profile_provider.dart"
Cohesion: 0.48
Nodes (6): build, ProfileNotifier, profileRepositoryProvider, updateAvatarUrl, updateName, package:ai_nexus/features/profile/data/profile_repository.dart

### Community 64 - "bounceable.dart"
Cohesion: 0.14
Nodes (13): build, child, _controller, createState, dispose, initState, onTap, _onTapCancel (+5 more)

### Community 65 - "exploreCategoryProvider"
Cohesion: 0.50
Nodes (4): exploreCategoryProvider, build, ExploreCategories, _handleTap

### Community 66 - "schedule_event_card.dart"
Cohesion: 0.14
Nodes (14): build, _controller, createState, dispose, event, _getOrdinal, initState, _onTapCancel (+6 more)

### Community 67 - "app_header.dart"
Cohesion: 0.14
Nodes (12): AppHeader, build, isDarkMode, onThemeToggle, pageTitle, subtitle, build, HomeHeader (+4 more)

### Community 68 - "featured_event_card.dart"
Cohesion: 0.17
Nodes (11): build, date, heroTag, imageUrl, isBookmarked, location, onBookmark, onRegister (+3 more)

### Community 69 - "custom_text_field.dart"
Cohesion: 0.22
Nodes (8): IconData, build, controller, CustomTextField, hintText, keyboardType, prefixIcon, TextInputType

### Community 70 - "event_repository.dart"
Cohesion: 0.22
Nodes (8): EventRepository, getEventById, getEvents, getEventsByFilter, searchEvents, toggleBookmark, HttpEventRepository, MockEventRepository

### Community 71 - "authProvider"
Cohesion: 0.17
Nodes (15): HookConsumerWidget, authProvider, AuthScreen, build, sendResetEmail, build, build, SignUpScreen (+7 more)

### Community 72 - "Decision Categories"
Cohesion: 0.18
Nodes (10): Active Decisions, Architecture, Backend (Context Only), Data Layer, Decision Categories, Decisions, Development Process, Notes (+2 more)

### Community 73 - "App Fix List — Global AI Opportunity Tracker"
Cohesion: 0.33
Nodes (5): App Fix List — Global AI Opportunity Tracker, 🔴 Critical Fixes, 🟡 Medium Fixes, 🟢 Polish Fixes, Progress

### Community 74 - "QueryBuilder"
Cohesion: 0.20
Nodes (10): EventEntityQueryFilter, EventEntityQueryLinks, EventEntityQueryObject, EventEntityQueryProperty, EventEntityQuerySortBy, EventEntityQuerySortThenBy, EventEntityQueryWhere, EventEntityQueryWhereDistinct (+2 more)

### Community 75 - "mock_event_repository.dart"
Cohesion: 0.22
Nodes (8): _events, getEventById, getEvents, getEventsByFilter, searchEvents, toggleBookmark, package:ai_nexus/core/mock/mock_events.dart, package:ai_nexus/features/events/repositories/event_repository.dart

### Community 76 - "package:flutter/material.dart"
Cohesion: 0.15
Nodes (11): build, currentStep, totalSteps, build, ExploreScreen, package:ai_nexus/features/explore/widgets/explore_categories.dart, package:ai_nexus/features/explore/widgets/explore_filter_chips.dart, package:ai_nexus/features/explore/widgets/explore_results.dart (+3 more)

### Community 77 - "Development Status"
Cohesion: 0.33
Nodes (5): Development Status, Milestone Status, Overall Status, Phase Summary, Status Change Log

### Community 78 - "Task Queue"
Cohesion: 0.33
Nodes (5): Currently Active Tasks, Notes, Task Discovery Log, Task Queue, Upcoming Tasks (Next Phase)

### Community 79 - "@freezed"
Cohesion: 0.40
Nodes (5): @freezed, EventModel, UserModel, EventModel, _EventModel

### Community 80 - "otp_input_field.dart"
Cohesion: 0.13
Nodes (13): HookWidget, AppTheme, build, length, onCompleted, OtpInputField, build, controller (+5 more)

### Community 81 - "package:ai_nexus/features/auth/models/user_model.dart"
Cohesion: 0.40
Nodes (4): currentUser, MockUser, package:ai_nexus/features/auth/models/user_model.dart, static const UserModel

### Community 82 - "env_config.dart"
Cohesion: 0.20
Nodes (9): _apiBaseUrl, EnvConfig, _initialized, load, _resolveApiBaseUrl, package:device_info_plus/device_info_plus.dart, package:flutter_dotenv/flutter_dotenv.dart, static bool (+1 more)

### Community 83 - "explore_filter_chips.dart"
Cohesion: 0.33
Nodes (6): exploreFilterProvider, build, ExploreFilterChips, _filters, package:ai_nexus/features/explore/providers/explore_provider.dart, package:ai_nexus/features/explore/widgets/animated_filter_chip.dart

### Community 84 - "validators.dart"
Cohesion: 0.50
Nodes (3): email, required, Validators

### Community 85 - "main.dart"
Cohesion: 0.14
Nodes (13): android, DefaultFirebaseOptions, web, initializeApp, load, main, package:ai_nexus/app.dart, package:ai_nexus/core/config/env_config.dart (+5 more)

### Community 86 - "Known Issues"
Cohesion: 0.50
Nodes (3): Active Blockers, Known Issues, Resolved Issues

### Community 103 - "dio_client.dart"
Cohesion: 0.29
Nodes (6): Dio, Dio get, _dio, _logger, package:ai_nexus/core/constants/api_constants.dart, package:ai_nexus/core/network/auth_interceptor.dart

### Community 104 - "auth_interceptor.dart"
Cohesion: 0.22
Nodes (8): Interceptor, AuthInterceptor, onError, onRequest, _secureStorage, SecureStorage, package:ai_nexus/core/storage/secure_storage.dart, package:dio/dio.dart

### Community 105 - "app_shadows.dart"
Cohesion: 0.40
Nodes (4): AppShadows, card, floatingButton, static const List

### Community 106 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.33
Nodes (3): package:flutter_riverpod/flutter_riverpod.dart, package:flutter_test/flutter_test.dart, main

### Community 107 - "_ProfileScreenState"
Cohesion: 0.50
Nodes (5): userInterestsProvider, build, _ProfileScreenState, scheduleTabProvider, Route /schedule

### Community 108 - "location_provider.dart"
Cohesion: 0.14
Nodes (13): getCurrentLocation, getServiceStatusStream, locationService, locationServiceStatusProvider, getCurrentLocation, LocationService, _logger, openSettings (+5 more)

### Community 110 - "explore_provider.dart"
Cohesion: 0.14
Nodes (12): AsyncValue, events, MockEvents, activeCategory, activeCity, activeFilter, eventsAsyncValue, searchQuery (+4 more)

### Community 112 - "events_provider.dart"
Cohesion: 0.28
Nodes (8): AsyncNotifier, eventRepositoryProvider, build, EventsNotifier, toggleBookmark, List, package:ai_nexus/core/providers/location_provider.dart, package:ai_nexus/core/providers/repository_providers.dart

### Community 113 - "http_event_repository.dart"
Cohesion: 0.15
Nodes (12): _bookmarkedIds, _bookmarksLoaded, _dio, _ensureBookmarksLoaded, getEventById, getEvents, getEventsByFilter, _mapOpportunityToEvent (+4 more)

### Community 114 - "schedule_screen.dart"
Cohesion: 0.10
Nodes (21): eventsProvider, _buildBottomBar, _findEvent, _handleRegistration, _onRefresh, _startFeaturedTimer, build, _buildEmptyState (+13 more)

## Knowledge Gaps
- **1051 isolated node(s):** `XCTest`, `EnvConfig`, `_initialized`, `_apiBaseUrl`, `load` (+1046 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **15 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SecureStorage` connect `auth_interceptor.dart` to `repository_providers.dart`, `http_event_repository.dart`, `providers.dart`, `secure_storage.dart`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **Why does `Phase 01 — Research & Design System` connect `Phase 01 — Research & Design System` to `ROADMAP.md`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **Why does `Phase 06 — Event Details` connect `Phase 06 — Event Details` to `ROADMAP.md`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **What connects `XCTest`, `EnvConfig`, `_initialized` to the rest of the system?**
  _1051 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `event_collection.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.009302325581395349 - nodes in this community are weakly interconnected._
- **Should `auth_provider.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._
- **Should `GeneratedPluginRegistrant.swift` be split into smaller, more focused modules?**
  _Cohesion score 0.125 - nodes in this community are weakly interconnected._