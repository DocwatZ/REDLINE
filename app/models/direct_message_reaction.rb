# frozen_string_literal: true
class DirectMessageReaction < ApplicationRecord
  belongs_to :direct_message
  belongs_to :user
  validates :emoji, presence: true, length: { maximum: 8 }
end
