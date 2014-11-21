class CreateReportValorizations < ActiveRecord::Migration
  def change
    create_table :report_valorizations do |t|
      t.integer :valorization_id
      t.string :order
      t.string :description
      t.float :price
      t.float :con_measured
      t.float :con_amount
      t.float :pre_measured
      t.float :pre_amount
      t.float :act_measured
      t.float :act_amount
      t.float :acc_measured
      t.float :acc_amount
      t.float :rem_measured
      t.float :rem_amount
      t.float :advance

      t.timestamps
    end
  end
end
