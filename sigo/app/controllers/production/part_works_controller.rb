class Production::PartWorksController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]  
  def index
    @company = get_company_cost_center('company')
    cost_center = get_company_cost_center('cost_center')
    @part_works = PartWork.where("cost_center_id = ?", cost_center)
    render layout: false
  end

  def show
    @partwork = PartWork.find(params[:id])
    @partworkdetails = @partwork.part_work_details
    @company = params[:company_id]
    render layout: false
  end

  #def display_articles
  #  word = params[:q]
  #  article_hash = Array.new
  #  name = get_company_cost_center('cost_center')
  #  articles = PartWork.getOwnArticles(word, name)
  #  articles.each do |art|
  #    article_hash << {'id' => art[0], 'name' => art[1]}
  #  end
  #  render json: {:articles => article_hash}
  #end

  def new
    cost_center_id = get_company_cost_center('cost_center')
    @partwork = PartWork.new
    @working_groups = WorkingGroup.where("cost_center_id = ?", cost_center_id)
    @sectors = Sector.where("code LIKE '__' AND cost_center_id = ?", cost_center_id)
    #@articles = PartWork.getOwnArticles(cost_center_id)
    itembybudget_ids = SubcontractDetail.distinct.select(:itembybudget_id).map(&:itembybudget_id)
    @itembybudgets = Itembybudget.select(:id).select(:order).select(:item_code).select(:subbudgetdetail).where(:id => itembybudget_ids)
    @company = params[:company_id]
    @cc = get_company_cost_center('cost_center')
    render layout: false
  end

  def create
    partwork = PartWork.new(part_work_parameters)
    partwork.cost_center_id = get_company_cost_center('cost_center')
    partwork.block = 0
    if partwork.save
      flash[:notice] = "Se ha creado correctamente la parte de obra."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      partwork.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def add_more_article
    @reg_n = ((Time.now.to_f)*100).to_i
    itembybudget = Itembybudget.select(:id).select(:order).select(:item_code).select(:subbudgetdetail).find(params[:itembybudget_id])
    
    @id_itembybudget = itembybudget.id
    @name_itembybudget = itembybudget.subbudgetdetail
    @itembybudget_code = itembybudget.order

    render(partial: 'partwork_items', :layout => false)
  end

  def edit
    cost_center_id = get_company_cost_center('cost_center')
    itembybudget_ids = SubcontractDetail.distinct.select(:itembybudget_id).map(&:itembybudget_id)
    @partwork = PartWork.find(params[:id])
    @working_groups = WorkingGroup.where("cost_center_id = ?", cost_center_id)
    @partworkde = @partwork.part_work_details
    @itembybudgets = Itembybudget.select(:id).select(:order).select(:item_code).select(:subbudgetdetail).where(:id => itembybudget_ids)
    @unit = UnitOfMeasurement.all
    @sectors = Sector.where("code LIKE '__' AND cost_center_id = ?", cost_center_id)
    @action = 'edit'
    @cc = get_company_cost_center('cost_center')
    @reg_n = Time.now.to_i
    @company = params[:company_id]
    render layout: false
  end

  def update
    partwork = PartWork.find(params[:id])
    partwork.update_attributes(part_work_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index, company_id: params[:company_id]
  rescue ActiveRecord::StaleObjectError
      partwork.reload
      flash[:error] = "Alguien más ha modificado los datos en este instante. Intente Nuevamente."
      redirect_to :action => :index
  end

  def destroy
    partwork = PartWork.find(params[:id]) # Find main Obj
    PartWorkDetail.destroy_all "part_work_id = #{partwork.id}"
    partwork = PartWork.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el Grupo de Trabajo."
    render :json => partwork
  end

  private
  def part_work_parameters
    params.require(:part_work).permit(:working_group_id, :block, :sector_id, :lock_version, :number_working_group, :date_of_creation, part_work_details_attributes: [:id, :part_work_id, :itembybudget_id, :bill_of_quantitties, :description, :lock_version, :_destroy])
  end
end
