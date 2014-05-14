class CreateZipCodes < ActiveRecord::Migration
  def change
    create_table :zip_codes do |t|
      t.string :name
      t.string :zip_code

      t.timestamps
    end
  end
end
