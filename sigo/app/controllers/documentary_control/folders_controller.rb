class DocumentaryControl::FoldersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @fa_id=0
    if !params[:fa_id].nil? && params[:fa_id]!=""
      if params[:fa_id]!='0'
        @folder = Folder.where("cost_center_id ="+get_company_cost_center('cost_center').to_s+" AND folderfa_id="+params[:fa_id].to_s)
        @fa_id = params[:fa_id]
      else
        @folder = Folder.where("cost_center_id ="+get_company_cost_center('cost_center').to_s+" AND folderfa_id IS NULL")
      end
    else
      @folder = Folder.where("cost_center_id ="+get_company_cost_center('cost_center').to_s+" AND folderfa_id IS NULL")
    end
    render layout: false
  end

  def show
    render layout: false
  end

  def new
    @fa_id = params[:fa_id]  
    @cost_center = get_company_cost_center('cost_center')
    @folderfa = Folder.where("cost_center_id = ? AND code LIKE '__'", get_company_cost_center('cost_center').to_s)
    @folder = Folder.new
    render layout: false
  end

  def create
    flash[:error] = nil
    folder = Folder.new(folder_parameters)
    folder.cost_center_id = get_company_cost_center('cost_center')
    if folder.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index, fa_id: folder.folderfa_id
    else
      folder.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @folder = folder
      render :new, layout: false 
    end
  end

  def edit
    @folder = Folder.find(params[:id])
    @folderfa = Folder.where("cost_center_id = ? AND code LIKE '__'", get_company_cost_center('cost_center').to_s)
    @cost_center = get_company_cost_center('cost_center')
    @action = 'edit'
    render layout: false
  end

  def update
    folder = Folder.find(params[:id])
    folder.cost_center_id = get_company_cost_center('cost_center')
    if folder.update_attributes(folder_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      folder.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @folder = folder
      render :edit, layout: false
    end
  end

  def destroy
    fa_id = Folder.find(params[:id]).folderfa_id
    folder = Folder.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => {fa_id: fa_id}
  end

  private
  def folder_parameters
    params.require(:folder).permit(:name, :description, :folderfa_id)
  end
end