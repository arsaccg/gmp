class MainController < ApplicationController
  before_filter :authenticate_user!
  def index
    @flag = params[:flag]
    if @flag.nil?
      company_id = current_user.companies.first.id
      cost_center_id = current_user.cost_centers.find_by_company_id(company_id).id
      session[:company] = company_id
      session[:cost_center] = cost_center_id
      redirect_to :action => :home
    else
      render layout: false
    end
  end

  def home
    if get_company_cost_center('company').present? && get_company_cost_center('cost_center').present?
      @company = Company.find(get_company_cost_center('company'))
      @cost_center_name = CostCenter.find(get_company_cost_center('cost_center')).name
      render :show_panel, layout: 'dashboard'
    else
      redirect_to :controller => "errors", :action => "error_500"
    end
  end

  def show_panel
    session[:company] = params[:id]
    session[:cost_center] = params[:cost_center]
    redirect_to :action => :home
  end

  # Show Inbox Panel

  def inbox_task
    render layout: false
  end

  def display_general_table_messages
    @user = current_user
    @order_services = current_user.order_of_services.where(" state LIKE 'revised' ")
    @purchase_orders = current_user.purchase_orders.where(" state LIKE 'revised' ")
    @delivery_orders = current_user.delivery_orders.where(" state LIKE 'revised' ")
    render(partial: 'table_messages', :layout => false)
  end

  def display_table_messages_os
    @user = current_user
    @delivery_orders = current_user.deliver_orders.where(" state LIKE 'revised' ")
    render(partial: 'table_messages_os', :layout => false)
  end

  def display_table_messages_oc
    @user = current_user
    @purchase_orders = current_user.purchase_orders.where(" state LIKE 'revised' ")
    render(partial: 'table_messages_oc', :layout => false)
  end

  def display_table_messages_ose
    @user = current_user
    @order_services = current_user.order_of_services.where(" state LIKE 'revised' ")
    render(partial: 'table_messages_ose', :layout => false)
  end

end
