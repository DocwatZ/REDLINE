# frozen_string_literal: true

class HealthCheckService
  Result = Struct.new(:name, :status, :message, keyword_init: true)

  def self.check_all
    {
      database: check_database,
      redis: check_redis,
      action_cable: check_action_cable,
      livekit: check_livekit
    }
  end

  def self.healthy?
    results = check_all
    results[:database].status == :ok && results[:redis].status == :ok
  end

  def self.check_database
    ActiveRecord::Base.connection.execute("SELECT 1")
    Result.new(name: "database", status: :ok, message: "Connected")
  rescue StandardError => e
    Result.new(name: "database", status: :error, message: e.message)
  end

  def self.check_redis
    redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/0")
    redis = Redis.new(url: redis_url)
    pong = redis.ping
    redis.close
    Result.new(name: "redis", status: :ok, message: pong)
  rescue StandardError => e
    Result.new(name: "redis", status: :error, message: e.message)
  end

  def self.check_action_cable
    cable_config = Rails.application.config.action_cable
    adapter = cable_config.cable&.dig("adapter") || "unknown"
    Result.new(name: "action_cable", status: :ok, message: "Adapter: #{adapter}")
  rescue StandardError => e
    Result.new(name: "action_cable", status: :error, message: e.message)
  end

  def self.check_livekit
    livekit_url = ENV.fetch("LIVEKIT_URL", nil)
    return Result.new(name: "livekit", status: :warn, message: "Not configured") unless livekit_url

    # Simple HTTP check — LiveKit exposes HTTP on the same port
    http_url = livekit_url.gsub(/^ws/, "http")
    response = Faraday.get("#{http_url}/") { |req| req.options.timeout = 3 }
    Result.new(name: "livekit", status: :ok, message: "Reachable (#{response.status})")
  rescue StandardError => e
    Result.new(name: "livekit", status: :warn, message: e.message)
  end
end
