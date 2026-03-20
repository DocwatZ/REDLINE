# frozen_string_literal: true

class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.text       :body,       null: false
      t.references :room,       null: false, foreign_key: true
      t.references :user,       null: false, foreign_key: true
      t.references :parent,     foreign_key: { to_table: :messages }
      t.boolean    :edited,     null: false, default: false
      t.boolean    :deleted,    null: false, default: false

      t.timestamps null: false
    end

    add_index :messages, [ :room_id, :created_at ]
  end
end
