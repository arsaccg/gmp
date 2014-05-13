class Production::PartPeopleController < ApplicationController
  def index
    @company = params[:company_id]
    @part_people = PartPerson.all
    render layout: false
  end

  def show
    @partperson = PartPerson.find(params[:id])
    @partpersondetails = @partperson.part_person_details
    @company = params[:company_id]
    render layout: false
  end

  def new
    @partperson = PartPerson.new
    @working_groups = WorkingGroup.all
    @workers = Worker.all
    @company = params[:company_id]
    render layout: false
  end

  def create
    partperson = PartPerson.new(part_person_parameters)
    if partperson.save
      flash[:notice] = "Se ha creado correctamente la parte de obra."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      partperson.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def add_more_worker
    @reg_n = Time.now.to_i
    @sectors = Sector.where("code LIKE '__'")
    data_article_unit = params[:article_id].split('-')
    @article = Article.find(data_article_unit[0])
    @id_article = @article.id
    @name_article = @article.name
    @unitOfMeasurement = @article.unit_of_measurement.name
    render(partial: 'partwork_items', :layout => false)
  end

  def edit
    @partperson = PartPerson.find(params[:id])
    @working_groups = WorkingGroup.all
    @sectors = Sector.where("code LIKE '__'")
    @action = 'edit'
    @company = params[:company_id]
    render layout: false
  end

  def update
    partperson = PartPerson.find(params[:id])
    if partperson.update_attributes(part_person_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      partperson.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @partperson = partperson
      render :edit, layout: false
    end
  end

  def destroy
    partperson = PartPerson.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el Grupo de Trabajo."
    render :json => partperson
  end

  private
  def part_person_parameters
    params.require(:part_person).permit(:working_group_id, :number_working_group, :sector_id, :date_of_creation, part_person_details_attributes: [:id, :part_work_id, :article_id, :bill_of_quantitties, :description])
  end
end
