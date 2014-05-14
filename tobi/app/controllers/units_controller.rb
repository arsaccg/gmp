class UnitsController < ApplicationController
  
  def index
    #@project = Project.find(params[:project_id])
    @units = Unit.all

    render layout: false
  end
  
  def new
    @unit = Unit.new
    render layout: false
  end
  
  def edit
    @unit = Unit.find(params[:id])
    render layout: false
  end
  
  def show
    @unit = Unit.find(params[:id])
    render layout: false
  end
  
  def update
    @unit = Unit.find(params[:id])
  end
  
  def create
    unit = Unit.new(unit_parameters)
    unit.save
    redirect_to :action => 'index'
  end
  
  def destroy
    @unit = Unit.find(params[:id])
    Unit.destroy(@unit.id)
    @units = Unit.all
    render :index, layout: false
  end
  
  private
  def unit_parameters
    params.require(:unit).permit(:name, :symbol)
  end
  
  
  
end
