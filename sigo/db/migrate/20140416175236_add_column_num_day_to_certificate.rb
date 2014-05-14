class AddColumnNumDayToCertificate < ActiveRecord::Migration
  def change
    add_column :certificates, :num_days, :integer
  end
end
