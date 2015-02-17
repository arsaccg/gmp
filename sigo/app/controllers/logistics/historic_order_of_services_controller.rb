class Logistics::HistoricOrderOfServicesController < ApplicationController
  include ApplicationHelper
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]  
  def index
    @orders = OrderOfService.where("status = 0 AND cost_center_id = " + get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def show
    @company = params[:company_id]
    @orderOfService = OrderOfService.find(params[:id])
    @orderOfServiceDetails = @orderOfService.order_of_service_details
    render layout: false    
  end

  def new
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
