class DocumentaryControl::SecuritiesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @sec = Security.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def show
    @sec = Security.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def new
    @cost_center = get_company_cost_center('cost_center')
    @sec = Security.new
    render layout: false
  end

  def create
    flash[:error] = nil
    sec = Security.new(sec_parameters)
    sec.cost_center_id = get_company_cost_center('cost_center')
    if sec.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      sec.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @sec = sec
      render :new, layout: false 
    end
  end

  def edit
    @sec = Security.find(params[:id])
    @cost_center = get_company_cost_center('cost_center')
    @action = 'edit'
    render layout: false
  end

  def update
    sec = Security.find(params[:id])
    sec.cost_center_id = get_company_cost_center('cost_center')
    if sec.update_attributes(sec_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      sec.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @sec = sec
      render :edit, layout: false
    end
  end

  def destroy
    sec = Security.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => sec
  end

  private
  def sec_parameters
    params.require(:security).permit(:name, :description, :document)
  end
end