# frozen_string_literal: true

class AuditService
  def self.log(action:, user: nil, metadata: {}, request: nil)
    ip_address = if request && Rails.application.config.respond_to?(:audit_log_ips) && Rails.application.config.audit_log_ips
                   request.remote_ip
                 end

    AuditLog.log(
      action: action,
      user: user,
      metadata: metadata,
      ip_address: ip_address
    )
  rescue StandardError => e
    Rails.logger.error("AuditService error: #{e.message}")
  end
end
