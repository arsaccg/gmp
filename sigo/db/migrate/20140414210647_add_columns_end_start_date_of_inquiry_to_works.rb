class AddColumnsEndStartDateOfInquiryToWorks < ActiveRecord::Migration
  def change
    add_column :works, :start_date_of_inquiry, :date
    add_column :works, :end_date_of_inquiry, :date
  end
end
