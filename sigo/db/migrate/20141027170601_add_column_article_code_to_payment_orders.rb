class AddColumnArticleCodeToPaymentOrders < ActiveRecord::Migration
  def change
    add_column :payment_orders, :article_code, :string
  end
end
