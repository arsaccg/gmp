class Logistics::PurchaseOrdersController < ApplicationController
  def index
    @cost_center = CostCenter.all
    render layout: false
  end

  def show
  end

  def new
  end

  def show_delivery_order_item_field
    cost_center = CostCenter.find(params[:id])
    @deliveryOrders = cost_center.delivery_orders
    render(partial: 'table_items_order', :layout => false)
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
