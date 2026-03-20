# frozen_string_literal: true

class ChatChannel < ApplicationCable::Channel
  def subscribed
    @room = Room.find_by(id: params[:room_id])
    return reject unless @room && current_user.rooms.include?(@room)

    stream_from "chat_#{@room.id}"
  end

  def receive(data)
    return unless @room

    message = @room.messages.create!(
      user: current_user,
      body: data["body"].to_s.strip.first(4000)
    )

    ActionCable.server.broadcast("chat_#{@room.id}", render_message(message))
  end

  def unsubscribed
    stop_all_streams
  end

  private

  def render_message(message)
    {
      id: message.id,
      body: message.display_body,
      room_id: message.room_id,
      user_id: message.user_id,
      display_name: message.user.display_name,
      initials: message.user.initials,
      avatar_color: message.user.avatar_color,
      created_at: message.created_at.iso8601,
      edited: message.edited
    }
  end
end
