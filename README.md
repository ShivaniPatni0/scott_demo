# Digital Ebook Library

A full-stack ebook library app — Ruby on Rails API backend + Flutter frontend.
Users can upload, browse, search, read, download, and delete ebooks (PDF, EPUB)
in a bookshelf-style UI.

## Tech Stack

- **Backend:** Ruby on Rails 7 (API-only), SQLite (dev), Active Storage (local disk)
- **Frontend:** Flutter (Provider/ChangeNotifier for state), `http`, `syncfusion_flutter_pdfviewer` (or `flutter_pdfview`) for reading PDFs
- **Testing:** RSpec (backend), `flutter_test` (frontend)

## Repo Layout

```
ebook_library/
├── backend/    # Rails API — rails new + this overlay
├── frontend/   # Flutter app — flutter create + this overlay
└── README.md
```

## Quick Start

See `backend/README.md` and `frontend/README.md` for step-by-step setup.
In short:

```bash
# Backend
cd backend
bundle install
bin/rails db:create db:migrate db:seed
bin/rails s -p 3000

# Frontend (in a new terminal)
cd frontend
flutter pub get
flutter run
```

The Flutter app talks to `http://localhost:3000/api` (iOS simulator) or
`http://10.0.2.2:3000/api` (Android emulator) — see `lib/services/api_service.dart`.

## API Overview

| Method | Endpoint                     | Purpose                        |
|--------|-------------------------------|---------------------------------|
| GET    | `/api/ebooks`                 | List ebooks (supports `?q=`)    |
| POST   | `/api/ebooks`                 | Upload a new ebook               |
| GET    | `/api/ebooks/:id`              | Ebook details                   |
| GET    | `/api/ebooks/:id/download`     | Download the file                |
| DELETE | `/api/ebooks/:id`              | Delete an ebook                 |
| GET    | `/api/ebooks/search?q=keyword` | Search title/author/filename    |

## Active Storage Approach

Files (ebook + optional cover) are stored using Rails **Active Storage** with the
local disk service (`config/storage.yml` → `:local`). This keeps the assignment
runnable with zero external dependencies (no S3 keys needed) while remaining a
one-line change to swap in S3/GCS for production (`config.active_storage.service = :amazon` etc.).

## AI Tool Usage

_(Fill this in with your actual workflow before submitting — see the
"AI Usage Notes" template at the bottom of `backend/README.md`.)_

## Known Limitations

- EPUB reading in-app is stubbed to "download & open externally" unless you wire up
  an EPUB renderer package (see frontend README for options).
- No authentication/authorization — single shared library, as scoped by the assignment.
- Search is a simple `LIKE` query; fine for assignment scale, not full-text search at scale.
