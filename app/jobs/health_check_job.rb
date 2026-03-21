# frozen_string_literal: true

class HealthCheckJob < ApplicationJob
  queue_as :default

  def perform
    results = HealthCheckService.check_all
    healthy = HealthCheckService.healthy?

    unless healthy
      Rails.logger.warn("[HealthCheck] System degraded: #{results.map { |k, v| "#{k}=#{v.status}" }.join(', ')}")
    end

    # Re-enqueue for periodic checks (every 5 minutes)
    self.class.set(wait: 5.minutes).perform_later
  end
end
