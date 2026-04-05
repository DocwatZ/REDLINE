# frozen_string_literal: true

class AppSetting < ApplicationRecord
  SAFE_URL_SCHEMES = %w[http https mailto].freeze
  DEFAULT_REQUEST_ACCESS_URL = "https://steamcommunity.com/groups/G13UK/".freeze

  validates :request_access_url, length: { maximum: 2048 }, allow_blank: true
  validate :request_access_url_scheme

  # Returns the single settings record, creating it with defaults if absent.
  def self.instance
    first_or_create!(
      self_signup_enabled: true,
      request_access_url:  DEFAULT_REQUEST_ACCESS_URL
    )
  end

  private

  def request_access_url_scheme
    return if request_access_url.blank?

    scheme = URI.parse(request_access_url).scheme&.downcase || ""
    unless SAFE_URL_SCHEMES.include?(scheme)
      errors.add(:request_access_url, "must use http, https, or mailto scheme")
    end
  rescue URI::InvalidURIError
    errors.add(:request_access_url, "is not a valid URL")
  end
end
