# frozen_string_literal: true

class RecoveryCodeService
  # Generate recovery codes for a user
  def self.generate(user, count: 8)
    RecoveryCode.generate_for(user, count: count)
  end

  # Authenticate a user via recovery code
  def self.authenticate(username_or_email, plaintext_code)
    user = User.find_for_database_authentication(login: username_or_email)
    return nil unless user

    recovery_code = RecoveryCode.verify(user, plaintext_code)
    return nil unless recovery_code

    AuditService.log(
      action: "recovery_code.used",
      user: user,
      metadata: { recovery_code_id: recovery_code.id }
    )

    user
  end
end
