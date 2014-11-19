class DocumentaryControl::ArcheologiesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @arq = Archeology.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def show
    @arq = Archeology.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def new
    @cost_center = get_company_cost_center('cost_center')
    @arq = Archeology.new
    render layout: false
  end

  def create
    flash[:error] = nil
    arq = Archeology.new(arq_parameters)
    arq.cost_center_id = get_company_cost_center('cost_center')
    if arq.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      arq.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @arq = arq
      render :new, layout: false 
    end
  end

  def edit
    @arq = Archeology.find(params[:id])
    @cost_center = get_company_cost_center('cost_center')
    @action = 'edit'
    render layout: false
  end

  def update
    arq = Archeology.find(params[:id])
    arq.cost_center_id = get_company_cost_center('cost_center')
    if arq.update_attributes(arq_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      arq.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @arq = arq
      render :edit, layout: false
    end
  end

  def destroy
    arq = Archeology.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => arq
  end

  private
  def arq_parameters
    params.require(:archeology).permit(:name, :description, :document)
  end
end
