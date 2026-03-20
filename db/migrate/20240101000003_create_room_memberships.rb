# frozen_string_literal: true

class CreateRoomMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :room_memberships do |t|
      t.references :room, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string     :role, null: false, default: "member" # member, moderator, admin

      t.timestamps null: false
    end

    add_index :room_memberships, [ :room_id, :user_id ], unique: true
  end
end
