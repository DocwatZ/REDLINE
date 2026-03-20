# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :html, :turbo_stream

  protected

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end
end
