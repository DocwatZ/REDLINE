# frozen_string_literal: true

class RecoverySessionsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :redirect_if_signed_in

  def new
  end

  def create
    user = RecoveryCodeService.authenticate(
      params[:login],
      params[:recovery_code]
    )

    if user
      sign_in(user)
      AuditService.log(
        action: "recovery_code.login",
        user: user,
        request: request
      )
      redirect_to rooms_path, notice: "Signed in via recovery code. Consider generating new codes."
    else
      AuditService.log(
        action: "recovery_code.login_failed",
        metadata: { login: params[:login] },
        request: request
      )
      flash.now[:alert] = "Invalid username/email or recovery code."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def redirect_if_signed_in
    redirect_to rooms_path if user_signed_in?
  end
end
