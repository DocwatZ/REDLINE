# frozen_string_literal: true

class RecoveryCodesController < ApplicationController
  def show
    @recovery_codes = flash[:recovery_codes]
    redirect_to rooms_path unless @recovery_codes
  end

  # Regenerate recovery codes for current user
  def create
    @recovery_codes = RecoveryCodeService.generate(current_user)
    AuditService.log(
      action: "recovery_code.regenerated",
      user: current_user,
      request: request
    )
    render :show
  end
end
