class Logistics::UnitOfMeasurementsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @unitOfMeasures = UnitOfMeasurement.all
    if params[:task] == 'created' || params[:task] == 'edited'
      render layout: 'dashboard'
    else
      render layout: false
    end
  end

  def create
    unitOfMeasure = UnitOfMeasurement.new(unit_of_measure_parameters)
    if unitOfMeasure.save
      flash[:notice] = "Se ha creado correctamente la nueva unidad de medida."
      redirect_to :action => :index, :task => 'created'
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      render layout: false
    end

  end

  def edit
    @unitOfMeasure = UnitOfMeasurement.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def show
    @unitOfMeasure = UnitOfMeasurement.find(params[:id])
    render :show
  end

  def update
    unitOfMeasure = UnitOfMeasurement.find(params[:id])
    unitOfMeasure.update_attributes(unit_of_measure_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index, :task => 'edited'
  end

  def new
    @unitOfMeasure = UnitOfMeasurement.new
    render :new, layout: false
  end

  def destroy
  end

  private
  def unit_of_measure_parameters
    params.require(:unit_of_measurement).permit(:name)
  end

end
