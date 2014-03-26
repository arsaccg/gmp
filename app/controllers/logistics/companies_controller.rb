class Logistics::CompaniesController < ApplicationController
  def index
    @companies = Company.all
    render layout: false
  end

  def show

  end

  def new
    @company = Company.new
    render :new, layout: false
  end

  def create
    company = Company.new(company_parameters)
    if company.save
      flash[:notice] = "Se ha creado correctamente la nueva compañia."
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

  def show_all_companies
    render :all_companies, layout: false
  end

  private
  def company_parameters
    params.require(:company).permit(:name, :ruc)
  end
end
