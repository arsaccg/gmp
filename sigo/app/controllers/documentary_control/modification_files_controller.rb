class DocumentaryControl::ModificationFilesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @type_mo = TypeOfModificationFile.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def show
    @mo = ModificationFile.find(params[:id])
    render layout: false
  end

  def new
    @type_mo = TypeOfModificationFile.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    @cost_center = get_company_cost_center('cost_center')
    @mo = ModificationFile.new
    render layout: false
  end

  def create
    flash[:error] = nil
    mo = ModificationFile.new(mo_parameters)
    mo.cost_center_id = get_company_cost_center('cost_center')
    if mo.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      mo.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @mo = mo
      render :new, layout: false 
    end
  end

  def edit
    @mo = ModificationFile.find(params[:id])
    @cost_center = get_company_cost_center('cost_center')
    @type_mo = TypeOfModificationFile.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    @action = 'edit'
    render layout: false
  end

  def update
    mo = ModificationFile.find(params[:id])
    mo.cost_center_id = get_company_cost_center('cost_center')
    if mo.update_attributes(mo_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      mo.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @mo = mo
      render :edit, layout: false
    end
  end

  def destroy
    mo = ModificationFile.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => mo
  end

  def technical_files
    word = params[:wordtosearch]
    @tech = ModificationFile.where('name LIKE "%'+word.to_s+'%" OR description LIKE "%'+word.to_s+'%" AND cost_center_id = ?', get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  private
  def mo_parameters
    params.require(:modification_file).permit(:name, :description, :document, :type_of_modification_file_id)
  end
end