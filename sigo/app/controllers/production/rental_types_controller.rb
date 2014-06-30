class Production::RentalTypesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    flash[:error] = nil
    @rental = RentalType.all
    render layout: false
  end

  def show
    render layout: false
  end

  def new
    @rentaltype = RentalType.new
    render layout: false
  end

  def create
    flash[:error] = nil
    rental = RentalType.new(rental_parameters)
    if rental.save
      flash[:notice] = "Se ha creado correctamente la profesión."
      redirect_to :action => :index
    else
      rental.errors.messages.each do |attribute, error|
          puts error.to_s
          puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index
    end
  end

  def edit
    @rentaltype = RentalType.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    rental= RentalType.find(params[:id])
    if rental.update_attributes(rental_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      rental.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @rental = rental
      render :edit, layout: false
    end
  end

  def destroy
    rental = RentalType.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el tipo de Alquiler."
    render :json => rental
  end

  private
  def rental_parameters
    params.require(:rental_type).permit(:name)
  end
end