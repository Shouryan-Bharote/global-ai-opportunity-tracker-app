# Graph Report - .  (2026-07-06)

## Corpus Check
- Corpus is ~16,425 words - fits in a single context window. You may not need a graph.

## Summary
- 222 nodes · 281 edges · 25 communities (20 shown, 5 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 24 edges (avg confidence: 0.81)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Windows Platform Runner|Windows Platform Runner]]
- [[_COMMUNITY_Linux Platform Runner|Linux Platform Runner]]
- [[_COMMUNITY_iOS Plugin Registration|iOS Plugin Registration]]
- [[_COMMUNITY_Flutter App Core|Flutter App Core]]
- [[_COMMUNITY_Windows Flutter Window|Windows Flutter Window]]
- [[_COMMUNITY_iOS App Delegate|iOS App Delegate]]
- [[_COMMUNITY_macOS Platform Layer|macOS Platform Layer]]
- [[_COMMUNITY_Windows Utilities|Windows Utilities]]
- [[_COMMUNITY_Web PWA Manifest|Web PWA Manifest]]
- [[_COMMUNITY_Project Configuration|Project Configuration]]
- [[_COMMUNITY_Android Plugin Registration|Android Plugin Registration]]
- [[_COMMUNITY_iOS LLDB Helper|iOS LLDB Helper]]
- [[_COMMUNITY_Web Entry Point|Web Entry Point]]
- [[_COMMUNITY_Android Main Activity|Android Main Activity]]
- [[_COMMUNITY_App Icon Assets|App Icon Assets]]
- [[_COMMUNITY_Swift Package Manager|Swift Package Manager]]
- [[_COMMUNITY_Desktop Build Systems|Desktop Build Systems]]
- [[_COMMUNITY_iOS Build Environment|iOS Build Environment]]
- [[_COMMUNITY_macOS Build Environment|macOS Build Environment]]
- [[_COMMUNITY_iOS Launch Image|iOS Launch Image]]

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 22 edges
2. `MessageHandler` - 12 edges
3. `FlutterWindow` - 10 edges
4. `Create` - 10 edges
5. `WndProc` - 10 edges
6. `MessageHandler` - 9 edges
7. `_MyApplication` - 7 edges
8. `OnCreate` - 7 edges
9. `WindowClassRegistrar` - 7 edges
10. `Destroy` - 7 edges

## Surprising Connections (you probably didn't know these)
- `Linux Build System` --semantically_similar_to--> `Windows Build System`  [INFERRED] [semantically similar]
  linux/CMakeLists.txt → windows/CMakeLists.txt
- `Android App Icon` --semantically_similar_to--> `iOS App Icon`  [INFERRED] [semantically similar]
  android/app/src/main/res/mipmap-hdpi/ic_launcher.png → ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
- `iOS App Icon` --semantically_similar_to--> `macOS App Icon`  [INFERRED] [semantically similar]
  ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png → macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png
- `AI Nexus Flutter Project` --conceptually_related_to--> `Project Configuration`  [INFERRED]
  README.md → pubspec.yaml
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Multi-Platform Build Systems** — linux_cmakelists_linux_build, windows_cmakelists_windows_build, web_index_web_entry [INFERRED 0.75]
- **App Branding Assets** — app_icon_android, app_icon_ios, app_icon_macos, web_favicon, web_pwa_icon [INFERRED 0.85]

## Communities (25 total, 5 thin omitted)

### Community 0 - "Windows Platform Runner"
Cohesion: 0.09
Nodes (38): PluginRegistry, Point, RECT, Size, RegisterPlugins(), OnCreate, HWND, LPARAM (+30 more)

### Community 1 - "Linux Platform Runner"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 2 - "iOS Plugin Registration"
Cohesion: 0.13
Nodes (10): Flutter, FlutterSceneDelegate, GeneratedPluginRegistrant, +registerWithRegistry, SceneDelegate, RunnerTests, RunnerTests, NSObject (+2 more)

### Community 3 - "Flutter App Core"
Cohesion: 0.12
Nodes (16): build, _counter, createState, _incrementCounter, main, MyApp, MyHomePage, _MyHomePageState (+8 more)

### Community 4 - "Windows Flutter Window"
Cohesion: 0.12
Nodes (15): unique_ptr, DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+7 more)

### Community 5 - "iOS App Delegate"
Cohesion: 0.16
Nodes (10): Any, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, AppDelegate, Bool, AppDelegate, Bool (+2 more)

### Community 6 - "macOS Platform Layer"
Cohesion: 0.18
Nodes (9): Cocoa, FlutterMacOS, FlutterPluginRegistry, FlutterViewController, Foundation, RegisterGeneratedPlugins(), MainFlutterWindow, NSWindow (+1 more)

### Community 7 - "Windows Utilities"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 8 - "Web PWA Manifest"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 9 - "Project Configuration"
Cohesion: 0.29
Nodes (8): Lint Configuration, Cupertino Icons Dependency, Dart SDK 3.12.2+, Flutter Lints Dev Dependency, Material Design Integration, Project Configuration, AI Nexus Flutter Project, Flutter Framework

### Community 10 - "Android Plugin Registration"
Cohesion: 0.47
Nodes (4): GeneratedPluginRegistrant, String, FlutterEngine, Keep

### Community 11 - "iOS LLDB Helper"
Cohesion: 0.33
Nodes (5): handle_new_rx_page(), __lldb_init_module(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages., SBDebugger, SBFrame

### Community 12 - "Web Entry Point"
Cohesion: 0.67
Nodes (4): Web Favicon, PWA Manifest, Web Entry Point, Web PWA Icon

### Community 14 - "App Icon Assets"
Cohesion: 0.67
Nodes (3): Android App Icon, iOS App Icon, macOS App Icon

### Community 16 - "Desktop Build Systems"
Cohesion: 0.67
Nodes (3): GTK+ 3.0 Dependency, Linux Build System, Windows Build System

## Knowledge Gaps
- **39 isolated node(s):** `flutter_export_environment.sh script`, `+registerWithRegistry`, `title`, `_counter`, `main` (+34 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `FlutterWindow` connect `Windows Flutter Window` to `Windows Platform Runner`, `macOS Platform Layer`?**
  _High betweenness centrality (0.159) - this node is a cross-community bridge._
- **Why does `Win32Window` connect `Windows Platform Runner` to `Windows Flutter Window`?**
  _High betweenness centrality (0.102) - this node is a cross-community bridge._
- **Are the 4 inferred relationships involving `MessageHandler` (e.g. with `Destroy` and `GetClientArea`) actually correct?**
  _`MessageHandler` has 4 INFERRED edges - model-reasoned connections that need verification._
- **Are the 2 inferred relationships involving `Create` (e.g. with `Destroy` and `UpdateTheme`) actually correct?**
  _`Create` has 2 INFERRED edges - model-reasoned connections that need verification._
- **Are the 2 inferred relationships involving `WndProc` (e.g. with `GetThisFromHandle` and `MessageHandler`) actually correct?**
  _`WndProc` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `flutter_export_environment.sh script`, `+registerWithRegistry` to the rest of the system?**
  _40 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Windows Platform Runner` be split into smaller, more focused modules?**
  _Cohesion score 0.08879492600422834 - nodes in this community are weakly interconnected._