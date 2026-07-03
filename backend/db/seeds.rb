# Creates a couple of demo ebooks so the shelf isn't empty on first run.
# Requires a sample PDF at db/seed_files/sample.pdf — swap in real files if you have them.

sample_pdf_path = Rails.root.join("db", "seed_files", "sample.pdf")

unless File.exist?(sample_pdf_path)
  FileUtils.mkdir_p(File.dirname(sample_pdf_path))
  # Minimal valid single-page PDF so seeds work out of the box.
  File.binwrite(sample_pdf_path, <<~PDF)
    %PDF-1.1
    1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj
    2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj
    3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 200 200] >> endobj
    trailer << /Root 1 0 R >>
  PDF
end

[
  { title: "The Pragmatic Programmer", author: "Andrew Hunt" },
  { title: "Clean Code", author: "Robert C. Martin" },
  { title: "Rails 7 in Action", author: "Sagar Fab" }
].each do |attrs|
  ebook = Ebook.find_or_initialize_by(title: attrs[:title])
  ebook.author = attrs[:author]
  next if ebook.persisted?

  ebook.file.attach(
    io: File.open(sample_pdf_path),
    filename: "#{attrs[:title].parameterize}.pdf",
    content_type: "application/pdf"
  )
  ebook.save!
end

puts "Seeded #{Ebook.count} ebooks."
