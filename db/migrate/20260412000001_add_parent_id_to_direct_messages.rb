class AddParentIdToDirectMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :direct_messages, :parent_id, :bigint
    add_index :direct_messages, :parent_id
  end
end
