# frozen_string_literal: true

class HealthController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    results = HealthCheckService.check_all
    healthy = HealthCheckService.healthy?

    respond_to do |format|
      format.json do
        render json: {
          status: healthy ? "ok" : "degraded",
          timestamp: Time.current.iso8601,
          services: results.transform_values { |r| { status: r.status, message: r.message } }
        }, status: healthy ? :ok : :service_unavailable
      end
      format.html do
        @results = results
        @healthy = healthy
        render :show, layout: false
      end
    end
  end
end
