# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :room
  belongs_to :user
  belongs_to :parent, class_name: "Message", optional: true
  has_many :replies, class_name: "Message", foreign_key: :parent_id, dependent: :destroy

  MESSAGE_TYPES = %w[text system].freeze

  validates :body, presence: true, length: { maximum: 4000 }, unless: :e2ee_message?
  validates :ciphertext, presence: true, if: :e2ee_message?
  validates :message_type, inclusion: { in: MESSAGE_TYPES }

  before_validation :sanitize_body

  scope :recent, -> { order(created_at: :asc) }
  scope :visible, -> { where(deleted: false) }

  def display_body
    return "[message deleted]" if deleted?
    return "[encrypted]" if e2ee_message?
    body
  end

  def e2ee_message?
    ciphertext.present? || room&.e2ee_enabled?
  end

  def system?
    message_type == "system"
  end

  private

  def sanitize_body
    self.body = body.to_s.strip if body.present?
  end
end
