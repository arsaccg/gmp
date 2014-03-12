class AddColumnUserIdToStatePerOrderDetails < ActiveRecord::Migration
  def change
    add_column :state_per_order_details, :user_id, :integer
  end
end
