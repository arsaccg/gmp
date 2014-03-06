class Logistics::SubcategoriesController < ApplicationController
  before_filter :authenticate_user!

  def index

  end

  def show
    subcategory = Subcategory.find(params[:id])
    render :show
  end

  def new
    @SubCategories = Subcategory.new
    @Categories = Category.all
    render layout: false
  end

  def create
    subcategory = Subcategory.new(subcategory_parameters)
    subcategory.code = params[:extrafield]['first_code'].to_s + params[:subcategory]['code'].to_s
    if subcategory.save
      flash[:notice] = "Se ha creado correctamente la nueva unidad de medida."
      redirect_to url_for(:controller => :categories, :action => :index, :task => 'created')
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to url_for(:controller => :categories, :action => :index, :task => 'failed')
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
    subcategory.update_attributes(subcategory_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to url_for(:controller => :categories, :action => :index, :task => 'edited')
  end

  def destroy
    subcategory = Subcategory.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente la sub-categoria seleccionado."
    redirect_to url_for(:controller => :categories, :action => :index, :task => 'deleted')
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
