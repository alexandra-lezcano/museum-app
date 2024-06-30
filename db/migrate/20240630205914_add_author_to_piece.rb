class AddAuthorToPiece < ActiveRecord::Migration[7.1]
  def change
    add_reference :pieces, :author, null: true, foreign_key: true
  end
end
