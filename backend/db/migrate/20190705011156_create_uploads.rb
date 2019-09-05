class CreateUploads < ActiveRecord::Migration[5.2]
  def change
    create_table :uploads do |t|
      t.string :file
      t.integer :status
      t.string :type
      t.references :user, index: true, on_delete: :nullify

      t.timestamps
    end
  end
end
