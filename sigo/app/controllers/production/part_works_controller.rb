class Production::PartWorksController < ApplicationController
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
    @working_groups = WorkingGroup.all
    @sectors = Sector.where("code LIKE '__'")
    @articles = PartWork.getOwnArticles(cost_center_id)
    @company = params[:company_id]
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
    article = Article.select(:id).select(:name).select(:unit_of_measurement_id).find(params[:article_id])
    
    @id_article = article.id
    @name_article = article.name
    @unitOfMeasurement = article.unit_of_measurement.name

    render(partial: 'partwork_items', :layout => false)
  end

  def edit
    cost_center_id = get_company_cost_center('cost_center')
    @partwork = PartWork.find(params[:id])
    @working_groups = WorkingGroup.all
    @partworkde = @partwork.part_work_details
    @articles = PartWork.getOwnArticles(cost_center_id)
    @unit = UnitOfMeasurement.all
    @sectors = Sector.where("code LIKE '__'")
    @action = 'edit'
    @reg_n = Time.now.to_i
    @company = params[:company_id]
    render layout: false
  end

  def update
    partwork = PartWork.find(params[:id])
    if partwork.update_attributes(part_work_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      partwork.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @partwork = partwork
      render :edit, layout: false
    end
  end

  def destroy
    partwork = PartWork.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el Grupo de Trabajo."
    render :json => partwork
  end

  private
  def part_work_parameters
    params.require(:part_work).permit(:working_group_id, :block, :sector_id, :number_working_group, :date_of_creation, part_work_details_attributes: [:id, :part_work_id, :article_id, :bill_of_quantitties, :description])
  end
end
