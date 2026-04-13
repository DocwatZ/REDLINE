# frozen_string_literal: true

class RoomMembershipsController < ApplicationController
  before_action :set_room
  before_action :set_membership
  before_action :require_admin!

  def update
    new_role = params[:role].to_s
    unless RoomMembership::ROLES.include?(new_role)
      render json: { error: "Invalid role" }, status: :unprocessable_entity and return
    end

    # Prevent demoting the only admin
    if @membership.admin? && new_role != "admin"
      admin_count = @room.room_memberships.where(role: "admin").count
      if admin_count <= 1
        render json: { error: "Cannot remove the only admin" }, status: :unprocessable_entity and return
      end
    end

    @membership.update!(role: new_role)

    AuditService.log(
      action: "room.membership_role_changed",
      user: current_user,
      metadata: {
        room_id: @room.id,
        room_name: @room.name,
        target_user_id: @membership.user_id,
        new_role: new_role
      }
    )

    render json: { role: @membership.role, display_name: @membership.user.display_name }
  end

  private

  def set_room
    @room = Room.find_by!(slug: params[:room_id])
  end

  def set_membership
    @membership = @room.room_memberships.find_by!(user_id: params[:id])
  end

  def require_admin!
    membership = @room.membership_for(current_user)
    unless membership&.admin?
      render json: { error: "Forbidden" }, status: :forbidden
    end
  end
end
