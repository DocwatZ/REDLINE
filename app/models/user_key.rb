# frozen_string_literal: true

class UserKey < ApplicationRecord
  belongs_to :user

  validates :public_key, presence: true
  validates :user_id, uniqueness: true
end
