# frozen_string_literal: true

class RecoveryCode < ApplicationRecord
  belongs_to :user

  validates :code_digest, presence: true

  scope :unused, -> { where(used_at: nil) }

  def used?
    used_at.present?
  end

  def use!
    update!(used_at: Time.current)
  end

  # Verify a plaintext code against the stored digest
  def self.verify(user, plaintext_code)
    normalized = plaintext_code.to_s.strip.downcase.delete("-")
    user.recovery_codes.unused.find_each do |rc|
      if BCrypt::Password.new(rc.code_digest) == normalized
        rc.use!
        return rc
      end
    end
    nil
  end

  # Generate a set of recovery codes for a user
  def self.generate_for(user, count: 8)
    user.recovery_codes.destroy_all

    plaintext_codes = count.times.map do
      code = SecureRandom.hex(5) # 10 hex chars
      formatted = "#{code[0..4]}-#{code[5..9]}" # e.g. "a1b2c-d3e4f"
      digest = BCrypt::Password.create(code, cost: BCrypt::Engine.cost)
      user.recovery_codes.create!(code_digest: digest)
      formatted
    end

    plaintext_codes
  end
end
