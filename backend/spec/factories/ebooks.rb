FactoryBot.define do
  factory :ebook do
    title { Faker::Book.title }
    author { Faker::Book.author }

    after(:build) do |ebook|
      ebook.file.attach(
        io: StringIO.new("%PDF-1.1 fake pdf content"),
        filename: "#{ebook.title.parameterize}.pdf",
        content_type: "application/pdf"
      )
    end
  end
end
