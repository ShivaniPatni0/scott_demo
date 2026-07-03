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

I used **Claude** (Anthropic) throughout the development of this project as a pair-programming
and design assistant. Specifically:

- **Architecture & planning:** Discussed the overall project structure (Rails API + Flutter
  frontend split), Active Storage vs. manual file handling trade-offs, and the API route design
  summarized in the table above.
- **Backend implementation:** Used Claude to scaffold the `Ebook` model/migration, generate the
  `EbooksController` actions (index, create, show, download, destroy, search), and write
  associated RSpec tests and request specs.
- **Frontend implementation:** Used Claude to build out the Flutter widgets (bookshelf grid/list
  view, upload form, PDF viewer integration via `syncfusion_flutter_pdfviewer`), the
  `ApiService` HTTP client, and the `Provider`/`ChangeNotifier` state management setup.
- **Debugging:** Used Claude to troubleshoot CORS configuration between Rails and Flutter,
  Active Storage local disk URL generation, and Android emulator networking
  (`10.0.2.2` vs `localhost`).
- **Documentation:** Used Claude to help draft this README and the setup instructions in
  `backend/README.md` and `frontend/README.md`.

All AI-suggested code was reviewed, tested, and adjusted manually before being committed —
Claude was used as an accelerant, not a substitute for understanding the implementation.

## Known Limitations

- EPUB reading in-app is stubbed to "download & open externally" unless you wire up
  an EPUB renderer package (see frontend README for options).
- No authentication/authorization — single shared library, as scoped by the assignment.
- Search is a simple `LIKE` query; fine for assignment scale, not full-text search at scale.