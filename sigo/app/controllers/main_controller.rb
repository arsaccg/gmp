class MainController < ApplicationController
  before_filter :authenticate_user!
  def index
    @flag = params[:flag]
    if @flag.nil?
      company_id = current_user.companies.first.id rescue nil
      if !company_id.nil?
        if current_user.cost_centers.exists?
          cost_center_id = current_user.cost_centers.find_by_company_id(company_id).id
          session[:company] = company_id
          session[:cost_center] = cost_center_id
        else
          session[:company] = 0
          session[:cost_center] = 0
        end
      else
        session[:company] = 0
        session[:cost_center] = 0
      end
      redirect_to :action => :home
    else
      render layout: false
    end
  end

  def home
    if get_company_cost_center('company').present? && get_company_cost_center('cost_center').present?
      @company = Company.find(get_company_cost_center('company')) rescue nil
      @cost_center_detail = CostCenterDetail.find_by_cost_center_id(get_company_cost_center('cost_center')) rescue nil
      @cost_center = CostCenter.find(get_company_cost_center('cost_center')) rescue nil
      @cost_center_name = CostCenter.find(get_company_cost_center('cost_center')).name rescue nil
      if !@company.nil? && !@cost_center_name.nil?
        @others_cost_centers = @company.cost_centers.where('id != ?', get_company_cost_center('cost_center'))
        @total_pending = OrderOfService.where(" state LIKE 'issued' ").count + PurchaseOrder.where(" state LIKE 'issued' ").count + DeliveryOrder.where(" state LIKE 'issued' ").count + OrderOfService.where(" state LIKE 'revised' ").count + PurchaseOrder.where(" state LIKE 'revised' ").count + DeliveryOrder.where(" state LIKE 'revised' ").count
      end
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

  def management_dashboard
    @cost_centers = CostCenter.all
    puts @cost_centers
    render layout: false
  end

  def display_general_table_messages
    @user = current_user

    @order_services_issued = OrderOfService.where(" state LIKE 'issued' ")
    @purchase_orders_issued = PurchaseOrder.where(" state LIKE 'issued' ")
    @delivery_orders_issued = DeliveryOrder.where(" state LIKE 'issued' ")

    @order_services_revised = OrderOfService.where(" state LIKE 'revised' ")
    @purchase_orders_revised = PurchaseOrder.where(" state LIKE 'revised' ")
    @delivery_orders_revised = DeliveryOrder.where(" state LIKE 'revised' ")
    
    @workers = Worker.where("state LIKE 'registered'")

    render(partial: 'table_messages', :layout => false)
  end

  def display_table_messages_os
    @user = current_user
    @delivery_orders_issued = DeliveryOrder.where(" state LIKE 'issued' ")
    @delivery_orders_revised = DeliveryOrder.where(" state LIKE 'revised' ")
    render(partial: 'table_messages_os', :layout => false)
  end

  def display_table_messages_oc
    @user = current_user
    @purchase_orders_issued = PurchaseOrder.where(" state LIKE 'issued' ")
    @purchase_orders_revised = PurchaseOrder.where(" state LIKE 'revised' ")
    render(partial: 'table_messages_oc', :layout => false)
  end

  def display_table_messages_ose
    @user = current_user
    @order_services_issued = OrderOfService.where(" state LIKE 'issued' ")
    @order_services_revised = OrderOfService.where(" state LIKE 'revised' ")
    render(partial: 'table_messages_ose', :layout => false)
  end

  def display_worker_pending
    @user = current_user
    @workers = Worker.where("state LIKE 'registered'")
    render(partial: 'table_worker_pending', :layout => false)
  end

end
