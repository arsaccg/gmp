class Logistics::FormatsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  def index
    flash[:error] = nil
    @items = Format.all #.where(company_id: "#{params[:company_id]}")
    render layout: false
  end

  def show
    render :json => nil
  end

  def new
    @format = Format.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    item = Format.new(item_parameters)
    item.user_inserts_id = current_user.id
    if item.update_attributes(item_parameters)
      flash[:notice] = "Se ha creado correctamente el registro."
      redirect_to :action => :index
    else
      #"Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      item.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @format = item
      render :new, layout: false
    end
        
  end

  def edit
    @format = Format.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    flash[:error] = nil
    item = Format.find(params[:id])
    item.user_updates_id = current_user.id
    if item.update_attributes(item_parameters)
      flash[:notice] = "Se ha actualizado correctamente el registro."
      redirect_to :action => :index
    else
      item.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @format = item
      render :edit, layout: false
    end
  end

  def destroy
    flash[:error] = nil
    item = Format.find(params[:id])
    item.update_attributes({status: "D", user_updates_id: params[:current_user_id]})
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => item
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
  def item_parameters
    params.require(:format).permit(:name, :description)
  end
end
