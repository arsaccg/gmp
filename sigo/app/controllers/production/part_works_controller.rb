class Production::PartWorksController < ApplicationController
  def index
    @company = get_company_cost_center('company')
    @part_works = PartWork.all
    render layout: false
  end

  def show
    @partwork = PartWork.find(params[:id])
    @partworkdetails = @partwork.part_work_details
    @company = params[:company_id]
    render layout: false
  end

  def new
    @partwork = PartWork.new
    @working_groups = WorkingGroup.all
    @sectors = Sector.where("code LIKE '__'")
    @articles = TypeOfArticle.find(4).articles
    @company = params[:company_id]
    render layout: false
  end

  def create
    partwork = PartWork.new(part_work_parameters)
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
    @reg_n = Time.now.to_i
    data_article_unit = params[:article_id].split('-')
    @article = Article.find(data_article_unit[0])
    @id_article = @article.id
    @name_article = @article.name
    @unitOfMeasurement = @article.unit_of_measurement.name
    render(partial: 'partwork_items', :layout => false)
  end

  def edit
    @partwork = PartWork.find(params[:id])
    @working_groups = WorkingGroup.all
    @partworkde = PartWorkDetail.where("part_work_id LIKE ?", params[:id])
    @unit = UnitOfMeasurement.all
    @articles = TypeOfArticle.find(4).articles
    @sectors = Sector.where("code LIKE '__'")
    @action = 'edit'
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
    params.require(:part_work).permit(:working_group_id, :sector_id, :number_working_group, :date_of_creation, part_work_details_attributes: [:id, :part_work_id, :article_id, :bill_of_quantitties, :description])
  end
end
