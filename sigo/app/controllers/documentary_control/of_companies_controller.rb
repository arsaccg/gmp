class DocumentaryControl::OfCompaniesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @type_com = TypeOfCompany.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def show
    @com = OfCompany.find(params[:id])
    render layout: false
  end

  def new
    @cost_center = get_company_cost_center('cost_center')
    @com = OfCompany.new
    render layout: false
  end

  def create
    flash[:error] = nil
    com = OfCompany.new(com_parameters)
    com.cost_center_id = get_company_cost_center('cost_center')

    if com.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      com.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @com = com
      render :new, layout: false 
    end
  end

  def edit
    @com = OfCompany.find(params[:id])
    @cost_center = get_company_cost_center('cost_center')
    @action = 'edit'
    render layout: false
  end

  def update
    com = OfCompany.find(params[:id])
    com.cost_center_id = get_company_cost_center('cost_center')
    if com.update_attributes(com_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      com.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @com = com
      render :edit, layout: false
    end
  end

  def destroy
    com = OfCompany.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => com
  end

  private
  def com_parameters
    params.require(:of_company).permit(:name, :description, :document, {:type_of_company_ids => []})
  end
end