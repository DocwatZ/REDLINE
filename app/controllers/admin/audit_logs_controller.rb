# frozen_string_literal: true

class Admin::AuditLogsController < Admin::BaseController
  def index
    @audit_logs = AuditLog.recent.includes(:user)

    if params[:action_filter].present?
      @audit_logs = @audit_logs.by_action(params[:action_filter])
    end

    if params[:user_id].present?
      @audit_logs = @audit_logs.by_user(params[:user_id])
    end

    @audit_logs = @audit_logs.limit(100)
  end
end
