# frozen_string_literal: true

class Admin::DashboardController < Admin::BaseController
  def show
    @user_count = User.count
    @room_count = Room.count
    @message_count = Message.count
    @recent_logs = AuditLog.recent.limit(20).includes(:user)
    @health = HealthCheckService.check_all
  end
end
