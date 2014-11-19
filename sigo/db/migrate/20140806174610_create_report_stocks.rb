class CreateReportStocks < ActiveRecord::Migration
  def change
    create_table :report_stocks do |t|

      t.timestamps
    end
  end
end
