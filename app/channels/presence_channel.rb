# frozen_string_literal: true

class PresenceChannel < ApplicationCable::Channel
  def subscribed
    stream_from "presence"
    current_user.update_column(:status, "online")
    broadcast_presence
  end

  def away
    current_user.update_column(:status, "away")
    broadcast_presence
  end

  def unsubscribed
    current_user.update_column(:status, "offline")
    broadcast_presence
    stop_all_streams
  end

  private

  def broadcast_presence
    ActionCable.server.broadcast("presence", {
      user_id: current_user.id,
      display_name: current_user.display_name,
      status: current_user.status
    })
  end
end
