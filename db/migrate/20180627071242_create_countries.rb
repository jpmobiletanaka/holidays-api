class CreateCountries < ActiveRecord::Migration[5.2]
  def change
    create_table :countries do |t|
      t.string :country_code, index: true, null: false
      t.string :ja_name
      t.string :en_name
    end
  end
end
