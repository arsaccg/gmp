class Logistics::ExtraCalculationsController < ApplicationController
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @extra_calculations = ExtraCalculation.all
    render layout: false
  end

  def show
    @extra_calculation = ExtraCalculation.find(params[:id])
    render layout: false
  end

  def new
    @extra_calculation = ExtraCalculation.new
    render :new, layout: false
  end

  def create
    extra_calculation = ExtraCalculation.new(extra_calculation_parameters)
    if extra_calculation.save
      flash[:notice] = "Se ha creado correctamente la nueva compañia."
      redirect_to :action => :index
    else
      v.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
    # Load new()
    @extra_calculation = extra_calculation
    render :new, layout: false
    end
  end

  def edit
    @extra_calculation = ExtraCalculation.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    extra_calculation = ExtraCalculation.find(params[:id])
    if extra_calculation.update_attributes(extra_calculation_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      extra_calculation.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @extra_calculation = extra_calculation
      render :edit, layout: false
    end
  end

  def destroy
    extra_calculation = ExtraCalculation.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => extra_calculation
  end

  private
  def extra_calculation_parameters
    params.require(:extra_calculation).permit(:concept)
  end
end
