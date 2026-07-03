class Ebook < ApplicationRecord
  ALLOWED_CONTENT_TYPES = %w[application/pdf application/epub+zip].freeze
  MAX_FILE_SIZE = 50.megabytes

  has_one_attached :file
  has_one_attached :cover_image

  validates :title, presence: true
  validate :file_must_be_present
  validate :file_type_must_be_allowed
  validate :file_size_must_be_within_limit

  before_validation :derive_metadata_from_file

  scope :search, ->(query) {
    return all if query.blank?

    sanitized = "%#{query.strip}%"
    left_outer_joins(file_attachment: :blob)
      .where(
        "ebooks.title LIKE :q OR ebooks.author LIKE :q OR active_storage_blobs.filename LIKE :q",
        q: sanitized
      ).distinct
  }

  def file_type
    file.attached? ? file.blob.content_type : nil
  end

  def file_size
    file.attached? ? file.blob.byte_size : nil
  end

  def filename
    file.attached? ? file.blob.filename.to_s : nil
  end

  private

  def derive_metadata_from_file
    return unless file.attached?

    self.author = author.presence || "Unknown"
  end

  def file_must_be_present
    errors.add(:file, "must be attached") unless file.attached?
  end

  def file_type_must_be_allowed
    return unless file.attached?

    unless ALLOWED_CONTENT_TYPES.include?(file.blob.content_type)
      errors.add(:file, "must be a PDF or EPUB")
    end
  end

  def file_size_must_be_within_limit
    return unless file.attached?

    if file.blob.byte_size > MAX_FILE_SIZE
      errors.add(:file, "must be smaller than #{MAX_FILE_SIZE / 1.megabyte}MB")
    end
  end
end
