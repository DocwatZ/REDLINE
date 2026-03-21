# frozen_string_literal: true

class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :lock, :unlock, :reset_password]

  def index
    @users = User.order(created_at: :desc).limit(50)
  end

  def show
    @audit_logs = @user.audit_logs.recent.limit(20)
    @identities = @user.identities
  end

  def lock
    AdminService.lock_account(admin: current_user, user: @user)
    redirect_to admin_user_path(@user), notice: "Account locked."
  rescue StandardError => e
    redirect_to admin_user_path(@user), alert: e.message
  end

  def unlock
    AdminService.unlock_account(admin: current_user, user: @user)
    redirect_to admin_user_path(@user), notice: "Account unlocked."
  rescue StandardError => e
    redirect_to admin_user_path(@user), alert: e.message
  end

  def reset_password
    new_password = params[:new_password]
    if new_password.blank? || new_password.length < 12
      redirect_to admin_user_path(@user), alert: "Password must be at least 12 characters."
      return
    end

    AdminService.reset_password(admin: current_user, user: @user, new_password: new_password)
    redirect_to admin_user_path(@user), notice: "Password reset successfully."
  rescue StandardError => e
    redirect_to admin_user_path(@user), alert: e.message
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
