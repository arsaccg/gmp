class Logistics::CompaniesController < ApplicationController
  def index
    @companies = Company.all
    render layout: false
  end

  def show

  end

  def new
    @company = Company.new
    render layout: false
  end

  def create
    company = Company.new(company_parameters)
    entity = Entity.new(entity_parameters)
    if company.save && entity.save
      entitytypeentity = EntitiesTypeEntities.create(entity_id: entity.id, type_entity_id: 1)
      flash[:notice] = "Se ha creado correctamente la nueva compania."
      redirect_to :action => :index
    else
      company.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
    # Load new()
    @company = company
    render :new, layout: false
    end
  end

  def edit
    @company = Company.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    company = Company.find(params[:id])
    if company.update_attributes(company_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      company.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @company = company
      render :edit, layout: false
    end
  end

  def destroy
    company = Company.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => company
  end

  private
  def company_parameters
    params.require(:company).permit(:name, :ruc, :address, :avatar, :short_name)
  end
  def entity_parameters
    params.require(:company).permit(:name, :ruc, :address)
  end
end
