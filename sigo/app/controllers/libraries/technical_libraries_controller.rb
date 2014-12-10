class Libraries::TechnicalLibrariesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @type_lib = TypeOfTechnicalLibrary.all
    @cc = CostCenter.find(get_company_cost_center('cost_center')).speciality.to_s
    render layout: false
  end

  def show
    @lib = TechnicalLibrary.find(params[:id])
    render layout: false
  end

  def new
    @type_lib = TypeOfTechnicalLibrary.all
    @lib = TechnicalLibrary.new
    render layout: false
  end

  def create
    flash[:error] = nil
    lib = TechnicalLibrary.new(lib_parameters)
    if lib.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      lib.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @lib = lib
      render :new, layout: false 
    end
  end

  def edit
    @lib = TechnicalLibrary.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    lib = TechnicalLibrary.find(params[:id])
    if lib.update_attributes(lib_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      lib.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @lib = lib
      render :edit, layout: false
    end
  end

  def destroy
    lib = TechnicalLibrary.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => lib
  end

  private
  def lib_parameters
    params.require(:technical_library).permit(:name, :description, :document, {:type_of_technical_library_ids => []}, :type_of_cost_center)
  end
end