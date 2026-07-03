# Manual Testing Checklist

## Setup
- [ ] `bin/rails s -p 3000` starts without errors
- [ ] `flutter run` builds and connects to the backend (library screen loads)

## Empty state
- [ ] Fresh DB (`bin/rails db:reset`, skip seeds) shows "Your shelf is empty" with an Add Ebook button

## Upload
- [ ] Upload a valid PDF with title + author → appears on shelf immediately
- [ ] Upload without selecting a file → inline validation error, no request sent
- [ ] Upload without a title → form validation blocks submit
- [ ] Upload a non-PDF/EPUB file (e.g. .txt) → backend rejects, error shown in a snackbar
- [ ] Upload a file over the size limit → backend rejects with a clear message

## Listing
- [ ] All uploaded ebooks appear on the shelf, newest first
- [ ] Cover placeholder renders sensibly for ebooks with no cover image

## Search
- [ ] Searching by title returns matching ebooks only
- [ ] Searching by author returns matching ebooks only
- [ ] Searching a term with no matches shows "No ebooks match ..." (not a blank screen)
- [ ] Clearing the search restores the full list

## Reading
- [ ] Tapping a PDF ebook opens the in-app reader and pages render
- [ ] Tapping an EPUB shows the "download to read externally" fallback (unless EPUB viewer added)

## Download
- [ ] Download button in the reader triggers a file download / opens externally
- [ ] Backend `/download` endpoint returns the correct file for a valid id
- [ ] Backend `/download` returns 404 for a bad id

## Delete
- [ ] Long-press an ebook → confirmation dialog appears
- [ ] Confirming delete removes it from the shelf and the backend
- [ ] Canceling delete leaves the ebook untouched
- [ ] Simulated delete failure (e.g. stop the server mid-delete) rolls the UI back and shows an error

## Loading / error states
- [ ] Turning off the backend before launching the app shows the error view with Retry
- [ ] Retry re-fetches successfully once the backend is back up
