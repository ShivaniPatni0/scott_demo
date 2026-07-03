# Ebook Library — Rails API Backend

## 1. Generate the base app (once)

From `ebook_library/`:

```bash
rails new backend --api --database=sqlite3 --skip-test -T
```

This scaffolds the standard Rails boilerplate (`config/boot.rb`, `config/environment.rb`,
`bin/rails`, etc.) that doesn't need to be hand-written or reviewed.

## 2. Apply this overlay

Copy every file from `backend_overlay_files/` into the newly generated `backend/`,
overwriting where they collide (`Gemfile`, `config/routes.rb`):

```bash
cp -R backend_overlay_files/. backend/
```

## 3. One manual tweak — Active Storage URL host

Active Storage needs to know your host to generate file/download URLs outside
of a request (e.g. in JSON responses). Add this to `backend/config/environments/development.rb`,
inside the `Rails.application.configure do ... end` block:

```ruby
config.active_storage.service = :local
Rails.application.routes.default_url_options[:host] = "localhost"
Rails.application.routes.default_url_options[:port] = 3000
```

`config/storage.yml` already ships with a `local:` service from `rails new` — no changes needed there.

## 4. Install & set up the database

```bash
cd backend
bundle install
bin/rails active_storage:install   # generates the Active Storage migration
bin/rails db:create db:migrate
bin/rails db:seed                  # optional demo data
```

## 5. Run the server

```bash
bin/rails s -p 3000
```

Verify: `curl http://localhost:3000/api/ebooks` should return `[]` or your seed data.

## 6. Run tests

```bash
bin/rails generate rspec:install    # only if spec/rails_helper.rb wasn't already present
bundle exec rspec
```

Expected: all request specs in `spec/requests/api/ebooks_spec.rb` and model specs
in `spec/models/ebook_spec.rb` pass. Use `bundle exec rspec --format documentation`
for a readable pass/fail list to screenshot for your submission.

## API Summary

| Method | Endpoint                     | Notes                                   |
|--------|-------------------------------|------------------------------------------|
| GET    | `/api/ebooks`                 | `?q=` optional, filters same as `/search` |
| GET    | `/api/ebooks/search?q=`       | Search by title / author / filename       |
| GET    | `/api/ebooks/:id`              | Ebook detail incl. `file_url`, `cover_url`|
| POST   | `/api/ebooks`                 | multipart/form-data: `ebook[title]`, `ebook[author]`, `ebook[file]`, `ebook[cover_image]` |
| GET    | `/api/ebooks/:id/download`     | 302 redirect to the actual file           |
| DELETE | `/api/ebooks/:id`              | 204 on success                            |

### Error format

Validation errors: `{ "errors": ["Title can't be blank", "File must be a PDF or EPUB"] }` (422)
Not found: `{ "error": "Couldn't find Ebook with 'id'=999" }` (404)

## Active Storage Approach

Files are stored on local disk (`storage/` folder, gitignored) via Rails' built-in
Active Storage `local` service — no S3/GCS credentials needed to run this locally.
To move to cloud storage for production, add the relevant gem (`aws-sdk-s3` etc.),
configure a new service block in `config/storage.yml`, and set
`config.active_storage.service = :amazon` (or your provider) in `config/environments/production.rb`.
No model or controller code changes are required — that's the point of Active Storage.

## Known Limitations

- Single shared library — no per-user auth (out of scope per assignment brief).
- Search is a simple SQL `LIKE`; fine at this data scale.
- EPUB files are accepted and stored but not parsed for metadata on the backend
  (Flutter side handles EPUB rendering separately, see `frontend/README.md`).

---

## AI Usage Notes (template — fill in for your submission)

- **Tools used:** e.g. Claude Code for scaffolding controllers/specs, manually reviewed diffs.
- **What was AI-assisted:** e.g. initial CRUD controller, RSpec skeletons, CORS config.
- **What you changed/rejected:** e.g. "AI initially suggested storing files as BLOBs in
  Postgres; rejected in favor of Active Storage for simplicity and swappable backends."
- **How AI helped debug:** e.g. "Used it to diagnose a 500 on `/download` caused by
  missing `default_url_options` — traced with the error message, verified fix manually."
