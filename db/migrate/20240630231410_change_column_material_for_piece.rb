class ChangeColumnMaterialForPiece < ActiveRecord::Migration[7.1]
  def change
    change_column_null(:pieces, :material_id, true)
  end
end
