# frozen_string_literal: true

class CreateRooms < ActiveRecord::Migration[7.1]
  def change
    create_table :rooms do |t|
      t.string  :name,        null: false
      t.text    :description
      t.string  :room_type,   null: false, default: "text" # text, voice, announcement
      t.boolean :private,     null: false, default: false
      t.string  :slug,        null: false
      t.references :owner,    null: false, foreign_key: { to_table: :users }

      t.timestamps null: false
    end

    add_index :rooms, :slug, unique: true
    add_index :rooms, :name
  end
end
