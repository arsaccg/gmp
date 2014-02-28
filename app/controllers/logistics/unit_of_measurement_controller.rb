class Logistics::UnitOfMeasurementController < ApplicationController
  def index
    @unitOfMeasures = UnitOfMeasurement.all
    render layout: false
  end

  def create
    unitOfMeasure = UnitOfMeasurement.new(unit_of_measure_parameters)
    if unitOfMeasure.save?
      flash[:notice] = "Se ha creado correctamente la nueva unidad de medida."
      redirec_to :index
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      render :new
    end

  end

  def edit
    unitOfMeasure = UnitOfMeasurement.find(params[:id])
    render :edit
  end

  def show
    unitOfMeasure = UnitOfMeasurement.find(params[:id])
    render :show
  end

  def update
    unitOfMeasure = UnitOfMeasurement.find(params[:id])
    
  end

  def new
    @unitOfMeasure = UnitOfMeasurement.new
    render :new
  end

  def destroy
  end

  private
  def unit_of_measure_parameters
    params.require(:unit_of_measure).permit(:name)
  end

end
