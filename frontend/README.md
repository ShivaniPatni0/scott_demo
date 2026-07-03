# Ebook Library — Flutter Frontend

## 1. Generate the base app (once)

From `ebook_library/`:

```bash
flutter create --org com.sagarfab frontend
```

## 2. Apply this overlay

```bash
cp -R frontend_overlay_files/. frontend/
```

This overwrites `pubspec.yaml`, `lib/main.dart`, and adds the `lib/models`,
`lib/services`, `lib/screens`, `lib/widgets`, and `test/` folders.

## 3. Install packages

```bash
cd frontend
flutter pub get
```

## 4. Point it at your backend

- **iOS Simulator:** default `http://localhost:3000/api` works as-is.
- **Android Emulator:** run with
  `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api`
- **Physical device:** use your Mac's LAN IP, e.g.
  `flutter run --dart-define=API_BASE_URL=http://192.168.1.23:3000/api`
  (make sure the device is on the same Wi-Fi network as your Rails server)

## 5. Run the app

```bash
flutter run
```

Make sure the Rails backend (`bin/rails s -p 3000`) is running first — the
library screen fetches on launch and shows a clear error state with a
"Retry" button if it can't reach the server.

## 6. Run tests

```bash
flutter test
```

Covers: empty-state rendering, bookshelf cover rendering per ebook, tap-to-open
behavior, and initial provider state. Add integration tests under
`integration_test/` if you want end-to-end upload/search/delete coverage.

## App Structure

```
lib/
├── main.dart                    # app entry, theme, provider wiring
├── models/ebook.dart            # Ebook data class + JSON mapping
├── services/
│   ├── api_service.dart         # HTTP calls to the Rails API
│   └── library_provider.dart    # ChangeNotifier: list/search/upload/delete state
├── screens/
│   ├── library_screen.dart      # bookshelf + search + FAB, loading/empty/error states
│   ├── upload_screen.dart       # file picker + title/author form
│   └── reader_screen.dart       # in-app PDF viewer, EPUB falls back to download
└── widgets/
    ├── bookshelf.dart           # wooden-shelf grid layout (rows + shelf planks)
    ├── ebook_cover.dart         # cover image or generated placeholder tile
    └── state_views.dart         # Empty / Loading / Error reusable views
```

## State Management

Uses `provider` with a single `LibraryProvider` (`ChangeNotifier`) exposing an
explicit `LoadState` enum (`idle | loading | loaded | error`) so the UI never
has to guess — each state maps to exactly one widget in `library_screen.dart`.
Delete is optimistic (removes from the list immediately) with rollback on
failure, so the UI feels instant without lying about server state for long.

## EPUB Reading

EPUB uploads are accepted and stored by the backend, but in-app rendering is
intentionally out of scope for the base build (`reader_screen.dart` offers a
"Download" fallback instead of a blank/broken viewer). To add real in-app EPUB
support, integrate a package like `epub_view` or `vocsy_epub_viewer` and branch
on `ebook.isEpub` the same way PDF is handled.

## Known Limitations

- No offline caching of ebook files — every read/download goes to the network.
- Search debounce is fixed at 400ms; not user-configurable.
- No pull-to-refresh loading indicator distinct from the initial load spinner.
