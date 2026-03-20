# frozen_string_literal: true

class CreateDirectMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :direct_messages do |t|
      t.text       :body,       null: false
      t.references :sender,     null: false, foreign_key: { to_table: :users }
      t.references :recipient,  null: false, foreign_key: { to_table: :users }
      t.boolean    :read,       null: false, default: false
      t.boolean    :edited,     null: false, default: false
      t.boolean    :deleted,    null: false, default: false

      t.timestamps null: false
    end

    add_index :direct_messages, [ :sender_id, :recipient_id ]
    add_index :direct_messages, [ :recipient_id, :read ]
  end
end
