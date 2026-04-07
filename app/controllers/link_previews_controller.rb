# frozen_string_literal: true

class LinkPreviewsController < ApplicationController
  # GET /link_previews?url=https://example.com
  def show
    url = params[:url].to_s.strip
    if url.blank? || !url.match?(%r{\Ahttps?://}i)
      render json: { error: "Invalid URL" }, status: :bad_request
      return
    end

    preview = LinkPreview.find_or_fetch(url)
    if preview
      render json: preview.as_preview_json
    else
      render json: { error: "Could not fetch preview" }, status: :not_found
    end
  end
end
