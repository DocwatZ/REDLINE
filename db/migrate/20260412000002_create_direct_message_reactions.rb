class CreateDirectMessageReactions < ActiveRecord::Migration[7.1]
  def change
    create_table :direct_message_reactions do |t|
      t.bigint :direct_message_id, null: false
      t.bigint :user_id, null: false
      t.string :emoji, null: false
      t.timestamps
    end
    add_index :direct_message_reactions, [:direct_message_id, :user_id, :emoji], unique: true,
              name: "idx_dm_reactions_unique"
    add_index :direct_message_reactions, :user_id
  end
end
