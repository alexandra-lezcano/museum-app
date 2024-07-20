class AddIsPermanentToCollections < ActiveRecord::Migration[7.1]
  def change
    add_column :piece_collections, :is_permanent, :boolean, :default => false
    add_column :piece_collections, :not_permanent_description, :text
  end
end
