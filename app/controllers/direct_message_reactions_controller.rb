# frozen_string_literal: true
class DirectMessageReactionsController < ApplicationController
  def toggle
    @dm = DirectMessage.find(params[:direct_message_id])
    unless @dm.sender_id == current_user.id || @dm.recipient_id == current_user.id
      head :forbidden and return
    end

    emoji = params[:emoji].to_s.strip.first(8)
    return head :unprocessable_entity if emoji.blank?

    existing = @dm.direct_message_reactions.find_by(user: current_user, emoji: emoji)
    if existing
      existing.destroy
    else
      @dm.direct_message_reactions.create!(user: current_user, emoji: emoji)
    end

    reactions = reaction_summary(@dm)
    conversation_key = [ @dm.sender_id, @dm.recipient_id ].sort.join("_")
    ActionCable.server.broadcast("dm_#{conversation_key}", {
      type: "reaction_update",
      dm_id: @dm.id,
      reactions: reactions
    })

    render json: { reactions: reactions }
  end

  private

  def reaction_summary(dm)
    dm.direct_message_reactions.group(:emoji).count.map do |e, c|
      { emoji: e, count: c, reacted: dm.direct_message_reactions.exists?(user_id: current_user.id, emoji: e) }
    end
  end
end
