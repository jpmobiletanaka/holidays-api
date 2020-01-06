class AddGinIndexToHolidays < ActiveRecord::Migration[5.2]
  def change
    add_index :holidays, %i[en_name], using: :gin, opclass: { en_name: :gin_trgm_ops }
  end
end
