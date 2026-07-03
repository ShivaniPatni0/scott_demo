module Api
  class EbooksController < ApplicationController
    before_action :set_ebook, only: [:show, :destroy, :download]

    # GET /api/ebooks
    # GET /api/ebooks?q=keyword    (also served by /api/ebooks/search)
    def index
      ebooks = Ebook.search(params[:q]).order(created_at: :desc)
      render json: ebooks.map { |e| ebook_json(e) }, status: :ok
    end

    # GET /api/ebooks/search?q=keyword
    def search
      index
    end

    # GET /api/ebooks/:id
    def show
      render json: ebook_json(@ebook, include_urls: true), status: :ok
    end

    # POST /api/ebooks
    def create
      ebook = Ebook.new(ebook_params)

      if ebook.save
        render json: ebook_json(ebook, include_urls: true), status: :created
      else
        render json: { errors: ebook.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # GET /api/ebooks/:id/download
    def download
      unless @ebook.file.attached?
        return render json: { error: "No file attached to this ebook" }, status: :not_found
      end

      redirect_to rails_blob_url(@ebook.file, disposition: "attachment")
    end

    # DELETE /api/ebooks/:id
    def destroy
      @ebook.destroy
      head :no_content
    rescue StandardError => e
      render json: { error: "Could not delete ebook: #{e.message}" }, status: :unprocessable_entity
    end

    private

    def set_ebook
      @ebook = Ebook.find(params[:id])
    end

    def ebook_params
      params.require(:ebook).permit(:title, :author, :file, :cover_image)
    end

    def ebook_json(ebook, include_urls: false)
      json = {
        id: ebook.id,
        title: ebook.title,
        author: ebook.author,
        file_type: ebook.file_type,
        file_size: ebook.file_size,
        filename: ebook.filename,
        created_at: ebook.created_at,
        updated_at: ebook.updated_at
      }

      if include_urls || true # cheap enough to always include for a library-scale app
        json[:cover_url] = ebook.cover_image.attached? ? url_for(ebook.cover_image) : nil
        json[:file_url] = ebook.file.attached? ? url_for(ebook.file) : nil
        json[:download_url] = ebook.file.attached? ? download_api_ebook_url(ebook) : nil
      end

      json
    end
  end
end
