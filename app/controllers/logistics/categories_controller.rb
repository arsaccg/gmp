class Logistics::CategoriesController < ApplicationController
  #before_filter :authenticate_user!
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @categories = Category.all
    if params[:task] == 'created' || params[:task] == 'edited'
      render layout: 'dashboard'
    else
      render layout: false
    end
  end

  def show
  end

  def new
    @category = Category.new
    render :new, layout: false
  end

  def create
    category = Category.new(category_parameters)
    if category.save
      flash[:notice] = "Se ha creado correctamente la nueva categoria."
      redirect_to :action => :index
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      render layout: false
    end
  end

  def update
    category = Category.find(params[:id])
    category.update_attributes(category_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index
  end

  def edit
    @category = Category.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def destroy
    category = Category.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => category
    #redirect_to :action => :index, :task => 'deleted'
  end

  private
  def category_parameters
    params.require(:category).permit(:code, :name)
  end
end
