class Libraries::LawAndRegulationsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @type_laws = TypeOfLawAndRegulation.all
    render layout: false
  end

  def show
    @law = LawAndRegulation.find(params[:id])
    render layout: false
  end

  def new
    @type_laws = TypeOfLawAndRegulation.all
    @laws = LawAndRegulation.new
    render layout: false
  end

  def create
    flash[:error] = nil
    laws = LawAndRegulation.new(law_repo_parameters)
    if laws.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      laws.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @laws = laws
      render :new, layout: false 
    end
  end

  def edit
    @laws = LawAndRegulation.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    laws = LawAndRegulation.find(params[:id])
    if laws.update_attributes(law_repo_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      laws.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @laws = laws
      render :edit, layout: false
    end
  end

  def destroy
    laws = LawAndRegulation.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => laws
  end

  private
  def law_repo_parameters
    params.require(:law_and_regulation).permit(:name, :description, :document, {:type_of_law_and_regulation_ids => []})
  end
end