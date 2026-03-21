# frozen_string_literal: true

class CreateRoomKeys < ActiveRecord::Migration[7.1]
  def change
    create_table :room_keys do |t|
      t.references :room, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :encrypted_room_key, null: false

      t.timestamps null: false
    end

    add_index :room_keys, [:room_id, :user_id], unique: true
  end
end
