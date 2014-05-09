class Production::CategoryOfWorkersController < ApplicationController
  def index
    @company = params[:company_id]
    @categoryOfWorker = CategoryOfWorker.all
    render layout: false
  end

  def show
    @categoryOfWorker = CategoryOfWorker.find(params[:id])
    render layout: false
  end

  def new
    @categoryOfWorker = CategoryOfWorker.new
    @unitOfMeasurements = UnitOfMeasurement.all
    @company = params[:company_id]
    render layout: false
  end

  def create
    categoryOfWorker = CategoryOfWorker.new(category_worker_parameters)
    if categoryOfWorker.save
      flash[:notice] = "Se ha creado correctamente la categoria del trabajador."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      categoryOfWorker.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def edit
    @categoryOfWorker = CategoryOfWorker.find(params[:id])
    @unitOfMeasurements = UnitOfMeasurement.all
    @company = params[:company_id]
    render layout: false
  end

  def update
    categoryOfWorker = CategoryOfWorker.find(params[:id])
    if categoryOfWorker.update_attributes(category_worker_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      categoryOfWorker.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @categoryOfWorker = categoryOfWorker
      render :edit, layout: false
    end
  end

  def destroy
    categoryOfWorker = CategoryOfWorker.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente la categoria del trabajor."
    render :json => categoryOfWorker
  end

  private
  def category_worker_parameters
    params.require(:category_of_worker).permit(:name, :normal_price, :he_60_price, :he_100_price, :unit_of_measurement_id)
  end
end
