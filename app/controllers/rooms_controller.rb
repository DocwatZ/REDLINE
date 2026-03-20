# frozen_string_literal: true

class RoomsController < ApplicationController
  before_action :set_room, only: [ :show, :update, :destroy, :join, :leave ]
  before_action :require_membership!, only: [ :show ]
  before_action :require_admin!, only: [ :update, :destroy ]

  def index
    @rooms = Room.public_rooms.by_name.includes(:owner, :room_memberships)
    @my_rooms = current_user.rooms.by_name.includes(:owner)
  end

  def show
    @messages = @room.messages.visible.recent.includes(:user).last(50)
    @members = @room.members.order(:display_name)
  end

  def new
    @room = Room.new
  end

  def create
    @room = current_user.owned_rooms.build(room_params)

    if @room.save
      redirect_to @room, notice: "Room created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @room.update(room_params)
      redirect_to @room, notice: "Room updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @room.destroy
    redirect_to rooms_path, notice: "Room deleted."
  end

  def join
    if @room.private?
      redirect_to rooms_path, alert: "This room is private."
      return
    end

    unless @room.member?(current_user)
      @room.room_memberships.create!(user: current_user, role: "member")
    end

    redirect_to @room
  end

  def leave
    membership = @room.membership_for(current_user)
    if membership&.admin? && @room.room_memberships.where(role: "admin").count == 1
      redirect_to @room, alert: "Transfer admin rights before leaving."
      return
    end

    membership&.destroy
    redirect_to rooms_path, notice: "You left #{@room.name}."
  end

  private

  def set_room
    @room = Room.find_by!(slug: params[:id])
  end

  def room_params
    params.require(:room).permit(:name, :description, :room_type, :private)
  end

  def require_membership!
    unless @room.member?(current_user) || !@room.private?
      redirect_to rooms_path, alert: "Access denied."
    end
  end

  def require_admin!
    membership = @room.membership_for(current_user)
    redirect_to @room, alert: "Admin access required." unless membership&.admin?
  end
end
