# frozen_string_literal: true

class RoomKey < ApplicationRecord
  belongs_to :room
  belongs_to :user

  validates :encrypted_room_key, presence: true
  validates :user_id, uniqueness: { scope: :room_id }
end
