class CreateHolidays < ActiveRecord::Migration
  def change
    create_table :holidays do |t|
      t.date :date_holiday
      t.string :title

      t.timestamps
    end
  end
end
