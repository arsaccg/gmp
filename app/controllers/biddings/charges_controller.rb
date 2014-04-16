class Biddings::ChargesController < ApplicationController
  
  def index
    flash[:error] = nil
    @charge = Charge.all
    render layout: false
  end

  def show
    render layout: false
  end

  def new
    @charge = Charge.new
    render layout: false
  end

  def create
    flash[:error] = nil
    charge = Charge.new(charge_parameters)
    if charge.save
      flash[:notice] = "Se ha creado correctamente el cargo."
      redirect_to :action => :index
    else
      charge.errors.messages.each do |attribute, error|
          puts error.to_s
          puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index
    end
  end

  def edit
    @charge = Charge.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    charge = Charge.find(params[:id])
    if charge.update_attributes(charge_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      charge.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @charge = charge
      render :edit, layout: false
    end
  end

  def destroy
    charge = Charge.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el cargo seleccionado."
    render :json => charge
  end

  private
  def charge_parameters
    params.require(:charge).permit(:name)
  end
end
