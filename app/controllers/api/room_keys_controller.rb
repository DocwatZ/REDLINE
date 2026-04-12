# frozen_string_literal: true

class Api::RoomKeysController < ApplicationController
  before_action :authenticate_user!

  # GET /api/room_keys/:room_id
  # Returns the encrypted room key for the current user in the given room,
  # along with the room owner's public key (used as the ECDH sender key).
  def show
    room = Room.find_by(id: params[:room_id])
    return render json: { error: "Room not found" }, status: :not_found unless room
    return render json: { error: "Access denied" }, status: :forbidden unless room.member?(current_user)

    room_key = RoomKey.find_by(room: room, user: current_user)
    return render json: { error: "No room key available" }, status: :not_found unless room_key

    # The room owner is the one who encrypts room keys for each member
    owner_key = UserKey.find_by(user: room.owner)
    return render json: { error: "Room owner has no public key" }, status: :not_found unless owner_key

    render json: {
      encrypted_room_key: room_key.encrypted_room_key,
      sender_public_key: owner_key.public_key
    }
  end
end
