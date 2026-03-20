# frozen_string_literal: true

class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end

  def update_status
    current_user.update!(status: params[:status]) if User::STATUSES.include?(params[:status])
    head :ok
  end
end
