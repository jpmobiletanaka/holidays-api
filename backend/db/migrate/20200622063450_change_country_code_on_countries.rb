class ChangeCountryCodeOnCountries < ActiveRecord::Migration[5.2]
  def up
    change_column :countries, :country_code, :string, limit: 2, null: false
    remove_index :countries, :country_code
    add_index :countries, :country_code, unique: true
  end

  def down
    change_column :countries, :country_code, :string, null: false
  end
end
