class Logistics::SubcategoriesController < ApplicationController
  #before_filter :authenticate_user!
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  def index

  end

  def show
    subcategory = Subcategory.find(params[:id])
    render :show
  end

  def new
    @SubCategories = Subcategory.new
    @Categories = Category.all
    render :new, layout: false
  end

  def create
    subcategory = Subcategory.new(subcategory_parameters)
    subcategory.code = params[:extrafield]['first_code'].to_s + params[:subcategory]['code'].to_s
    if subcategory.save
      flash[:notice] = "Se ha creado correctamente la nueva sub-categoria."
      redirect_to url_for(:controller => :categories, :action => :index)
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      render layout: false
    end
  end

  def edit
    @SubCategories = Subcategory.find(params[:id])
    @Categories = Category.all
    @action = 'edit'
    render layout: false
  end

  def update
    subcategory = Subcategory.find(params[:id])
    subcategory.category_id = params[:subcategory]['category_id'].to_s
    subcategory.code = params[:extrafield]['first_code'].to_s + params[:subcategory]['code'].to_s
    subcategory.name = params[:subcategory]['name'].to_s
    subcategory.save #update_attributes(subcategory_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to url_for(:controller => :categories, :action => :index)
    #redirect_to :action => :index
  end

  def destroy
    subcategory = Subcategory.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente la sub-categoria seleccionado."
    render :json => subcategory
    #redirect_to url_for(:controller => :categories, :action => :index, :task => 'deleted')
  end

  def get_subcategory_form_category
    @subcategories = Subcategory.where("category_id = ?", params[:category_id])
    render json: {:subcategories => @subcategories}  
  end

  private
  def subcategory_parameters
    params.require(:subcategory).permit(:category_id, :code, :name)
  end
end
