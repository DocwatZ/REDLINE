# frozen_string_literal: true

# Rack::Attack - Rate limiting and throttling for privacy and security
class Rack::Attack
  # Throttle sign-in attempts by IP
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == "/users/sign_in" && req.post?
  end

  # Throttle sign-in attempts by email
  throttle("logins/email", limit: 5, period: 20.seconds) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.params["user"]["email"].to_s.downcase.gsub(/\s+/, "").first(100)
    end
  end

  # Throttle sign-up attempts
  throttle("signup/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == "/users" && req.post?
  end

  # Throttle password reset requests
  throttle("passwords/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == "/users/password" && req.post?
  end

  # Throttle general API requests
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets", "/packs")
  end

  self.throttled_responder = lambda do |_env|
    [
      429,
      { "Content-Type" => "application/json" },
      [ { error: "Too many requests. Please slow down." }.to_json ]
    ]
  end
end
