class Libraries::TechnicalStandardsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @standard = TechnicalStandard.all
    render layout: false
  end

  def show
    @standard = TechnicalStandard.find(params[:id])
    render layout: false
  end

  def new
    @standard = TechnicalStandard.new
    render layout: false
  end

  def create
    flash[:error] = nil
    standard = TechnicalStandard.new(tech_parameters)
    if standard.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      standard.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @standard = standard
      render :new, layout: false 
    end
  end

  def edit
    @standard = TechnicalStandard.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    standard = TechnicalStandard.find(params[:id])
    if standard.update_attributes(tech_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      standard.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @standard = standard
      render :edit, layout: false
    end
  end

  def destroy
    standard = TechnicalStandard.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => standard
  end

  private
  def tech_parameters
    params.require(:technical_standard).permit(:name, :description, :document)
  end
end