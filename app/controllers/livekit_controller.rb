# frozen_string_literal: true

# Generates LiveKit access tokens for WebRTC voice/video sessions.
# The client uses this token to join a LiveKit room.
class LivekitController < ApplicationController
  def token
    room = Room.find_by!(slug: params[:room_id])
    membership = room.membership_for(current_user)

    unless membership || !room.private?
      render json: { error: "Access denied" }, status: :forbidden
      return
    end

    token = generate_livekit_token(room)
    render json: {
      token: token,
      url: ENV.fetch("LIVEKIT_URL", "ws://localhost:7880"),
      room: room.slug,
      identity: current_user.id.to_s
    }
  end

  private

  def generate_livekit_token(room)
    api_key    = ENV.fetch("LIVEKIT_API_KEY", "devkey")
    api_secret = ENV.fetch("LIVEKIT_API_SECRET", "devsecret")

    grants = {
      roomJoin: true,
      room: room.slug,
      canPublish: true,
      canSubscribe: true
    }

    token = JWT.encode(
      {
        iss: api_key,
        sub: current_user.id.to_s,
        iat: Time.now.to_i,
        exp: Time.now.to_i + 3600,
        nbf: Time.now.to_i - 10,
        name: current_user.display_name,
        video: grants
      },
      api_secret,
      "HS256"
    )

    token
  end
end
