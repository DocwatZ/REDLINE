# frozen_string_literal: true

class Admin::SystemController < Admin::BaseController
  def show
    @health = HealthCheckService.check_all
  end
end
