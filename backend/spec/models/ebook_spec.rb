require "rails_helper"

RSpec.describe Ebook, type: :model do
  it "is valid with a title and an attached PDF" do
    ebook = build(:ebook)
    expect(ebook).to be_valid
  end

  it "is invalid without a title" do
    ebook = build(:ebook, title: nil)
    expect(ebook).not_to be_valid
    expect(ebook.errors[:title]).to include("can't be blank")
  end

  it "is invalid without an attached file" do
    ebook = Ebook.new(title: "No File")
    expect(ebook).not_to be_valid
    expect(ebook.errors[:file]).to include("must be attached")
  end

  it "is invalid with a disallowed file type" do
    ebook = build(:ebook)
    ebook.file.attach(
      io: StringIO.new("not a pdf"),
      filename: "notes.txt",
      content_type: "text/plain"
    )
    expect(ebook).not_to be_valid
    expect(ebook.errors[:file]).to include("must be a PDF or EPUB")
  end

  describe ".search" do
    it "matches on title or author, case-insensitively for common cases" do
      match = create(:ebook, title: "Refactoring", author: "Martin Fowler")
      create(:ebook, title: "Domain-Driven Design", author: "Eric Evans")

      results = Ebook.search("fowler")
      expect(results).to include(match)
    end

    it "returns everything when the query is blank" do
      create_list(:ebook, 2)
      expect(Ebook.search(nil).count).to eq(2)
    end
  end
end
