class Logistics::SuppliersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  def index
    flash[:error] = nil
    @suppliers = Supplier.all
    render layout: false
  end

  def show
    render :json => nil
  end

  def new
    @suppliers = Supplier.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    supplier = Supplier.new(supplier_parameters)
    if supplier.save
      flash[:notice] = "Se ha creado correctamente el proveedor."
      redirect_to :action => :index
    else
      #"Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      supplier.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @suppliers = supplier
      render :new, layout: false
    end
        
  end

  def edit
    @suppliers = Supplier.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    flash[:error] = nil
    supplier = Supplier.find(params[:id])
    if supplier.update_attributes(supplier_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      supplier.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @suppliers = supplier
      render :edit, layout: false
    end
  end

  def destroy
    supplier = Supplier.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => supplier
  end

  def save
    if valid?
      #save method implementation
      true
    else
      false
    end
  end

  private
  def supplier_parameters
    params.require(:supplier).permit(:ruc, :name, :address, :phone)
  end
end
