class UnitOfMeasurementController < ApplicationController
  def index
    @unitOfMeasures = UnitOfMeasure.all
    render layout: false
  end

  def create
    unitOfMeasure = UnitOfMeasure.new(unit_of_measure_parameters)
    if unitOfMeasure.save?
      redirec_to :index
    else
      render :new
    end

  end

  def edit
    unitOfMeasure = unitOfMeasure.find(params[:id])
    render :edit
  end

  def show
    unitOfMeasure = unitOfMeasure.find(params[:id])
    render :show
  end

  def update
    unitOfMeasure = unitOfMeasure.find(params[:id])
    
  end

  def new
    unitOfMeasure = UnitOfMeasure.new
    render :new
  end

  def destroy
  end

  private
  def unit_of_measure_parameters
    params.require(:unit_of_measure).permit(:name)
  end

end
