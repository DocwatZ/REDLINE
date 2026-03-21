# frozen_string_literal: true

class AdminService
  # Reset a user's password — admin only
  def self.reset_password(admin:, user:, new_password:)
    raise "Unauthorized" unless admin.admin?
    raise "Cannot reset own password via admin flow" if admin.id == user.id

    user.update!(password: new_password, password_confirmation: new_password)

    AuditService.log(
      action: "admin.password_reset",
      user: admin,
      metadata: { target_user_id: user.id, target_username: user.username }
    )

    true
  end

  # Unlock a locked account — admin only
  def self.unlock_account(admin:, user:)
    raise "Unauthorized" unless admin.admin?

    user.unlock_access!

    AuditService.log(
      action: "admin.unlock_account",
      user: admin,
      metadata: { target_user_id: user.id, target_username: user.username }
    )

    true
  end

  # Lock a user account — admin only
  def self.lock_account(admin:, user:)
    raise "Unauthorized" unless admin.admin?
    raise "Cannot lock own account" if admin.id == user.id

    user.lock_access!(send_instructions: false)

    AuditService.log(
      action: "admin.lock_account",
      user: admin,
      metadata: { target_user_id: user.id, target_username: user.username }
    )

    true
  end
end
