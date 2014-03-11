class AddColumnCenterOfAttentionIdToDeliveryOrderDetails < ActiveRecord::Migration
  def change
    add_column :delivery_order_details, :center_of_attention_id, :integer
  end
end
