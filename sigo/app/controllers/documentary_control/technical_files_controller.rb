class DocumentaryControl::TechnicalFilesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @type_tech = TypeOfTechnicalFile.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def show
    @tech = TechnicalFile.find(params[:id])
    render layout: false
  end

  def new
    @type_tech = TypeOfTechnicalFile.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    @cost_center = get_company_cost_center('cost_center')
    @tech = TechnicalFile.new
    render layout: false
  end

  def create
    flash[:error] = nil
    tech = TechnicalFile.new(tech_parameters)
    tech.cost_center_id = get_company_cost_center('cost_center')
    if tech.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      tech.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @tech = tech
      render :new, layout: false 
    end
  end

  def edit
    @tech = TechnicalFile.find(params[:id])
    @cost_center = get_company_cost_center('cost_center')
    @action = 'edit'
    render layout: false
  end

  def update
    tech = TechnicalFile.find(params[:id])
    tech.cost_center_id = get_company_cost_center('cost_center')
    if tech.update_attributes(tech_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      tech.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @tech = tech
      render :edit, layout: false
    end
  end

  def destroy
    tech = TechnicalFile.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => tech
  end

  def technical_files
    word = params[:wordtosearch]
    @tech = TechnicalFile.where('name LIKE "%'+word.to_s+'%" OR description LIKE "%'+word.to_s+'%" AND cost_center_id = ?', get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  private
  def tech_parameters
    params.require(:technical_file).permit(:name, :description, :document, :type_of_technical_file_id)
  end
end