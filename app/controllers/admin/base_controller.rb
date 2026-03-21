# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  before_action :require_admin!

  layout "admin"

  private

  def require_admin!
    unless current_user&.admin?
      redirect_to rooms_path, alert: "Admin access required."
    end
  end
end
