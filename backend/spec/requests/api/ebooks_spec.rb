require "rails_helper"

RSpec.describe "Api::Ebooks", type: :request do
  let(:valid_pdf) do
    fixture_file_upload(
      Rails.root.join("spec/fixtures/files/sample.pdf"),
      "application/pdf"
    )
  end

  before(:all) do
    dir = Rails.root.join("spec/fixtures/files")
    FileUtils.mkdir_p(dir)
    File.binwrite(dir.join("sample.pdf"), "%PDF-1.1 fake content for specs")
  end

  describe "GET /api/ebooks" do
    it "returns all ebooks" do
      create_list(:ebook, 3)

      get "/api/ebooks"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(3)
    end

    it "returns an empty array when the library has no ebooks" do
      get "/api/ebooks"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end
  end

  describe "GET /api/ebooks/search" do
    it "filters by title" do
      create(:ebook, title: "Domain-Driven Design")
      create(:ebook, title: "Clean Architecture")

      get "/api/ebooks/search", params: { q: "Domain" }

      body = JSON.parse(response.body)
      expect(body.size).to eq(1)
      expect(body.first["title"]).to eq("Domain-Driven Design")
    end

    it "returns an empty array when nothing matches" do
      create(:ebook, title: "Domain-Driven Design")

      get "/api/ebooks/search", params: { q: "Nonexistent" }

      expect(JSON.parse(response.body)).to eq([])
    end
  end

  describe "GET /api/ebooks/:id" do
    it "returns the ebook" do
      ebook = create(:ebook)

      get "/api/ebooks/#{ebook.id}"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["id"]).to eq(ebook.id)
    end

    it "returns 404 for a missing ebook" do
      get "/api/ebooks/999999"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/ebooks" do
    it "creates an ebook with a valid PDF" do
      expect {
        post "/api/ebooks", params: { ebook: { title: "New Book", author: "Jane Doe", file: valid_pdf } }
      }.to change(Ebook, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "rejects an ebook without a title" do
      post "/api/ebooks", params: { ebook: { author: "Jane Doe", file: valid_pdf } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to include("Title can't be blank")
    end

    it "rejects an ebook without a file" do
      post "/api/ebooks", params: { ebook: { title: "No File Book" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to include("File must be attached")
    end

    it "rejects a disallowed file type" do
      bad_file = fixture_file_upload(
        Rails.root.join("spec/fixtures/files/sample.pdf"),
        "text/plain"
      )

      post "/api/ebooks", params: { ebook: { title: "Bad Type", file: bad_file } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to include("File must be a PDF or EPUB")
    end
  end

  describe "GET /api/ebooks/:id/download" do
    it "redirects to the file's blob URL" do
      ebook = create(:ebook)

      get "/api/ebooks/#{ebook.id}/download"

      expect(response).to have_http_status(:found)
    end

    it "returns 404 when the ebook has no file" do
      ebook = create(:ebook)
      ebook.file.purge

      get "/api/ebooks/#{ebook.id}/download"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/ebooks/:id" do
    it "deletes the ebook" do
      ebook = create(:ebook)

      expect {
        delete "/api/ebooks/#{ebook.id}"
      }.to change(Ebook, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 for a missing ebook" do
      delete "/api/ebooks/999999"

      expect(response).to have_http_status(:not_found)
    end
  end
end
