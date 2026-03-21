# frozen_string_literal: true

class AddE2eeAndRoomTypeToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :e2ee_enabled, :boolean, null: false, default: false
  end
end
