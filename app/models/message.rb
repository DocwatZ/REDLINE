# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :room
  belongs_to :user
  belongs_to :parent, class_name: "Message", optional: true
  has_many :replies, class_name: "Message", foreign_key: :parent_id, dependent: :destroy

  validates :body, presence: true, length: { maximum: 4000 }

  before_validation :sanitize_body

  scope :recent, -> { order(created_at: :asc) }
  scope :visible, -> { where(deleted: false) }

  def display_body
    deleted? ? "[message deleted]" : body
  end

  private

  def sanitize_body
    self.body = body.to_s.strip
  end
end
