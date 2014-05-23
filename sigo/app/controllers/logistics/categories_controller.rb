class Logistics::CategoriesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    flash[:error] = nil
    @categories =  Category.where("code LIKE '__' ")
    render layout: false
  end

  def show
  end

  def new
    @category = Category.new
    @cate = Category.where("code LIKE '__' ")
    @subcate = Category.where("code LIKE '____' ")
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    category = Category.new(category_parameters)
    category.code = params[:extrafield]['first_code'].to_s + params[:category]['code'].to_s
    if category.save
      flash[:notice] = "Se ha creado correctamente la nueva categoria."
      redirect_to :action => :index
    else
      category.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @category = category
      render :new, layout: false
    end
  end

  def update
    category = Category.find(params[:id])
    category.code = params[:extrafield]['first_code'].to_s + params[:category]['code'].to_s
    category.name = params[:category]['name'].to_s
    puts category.code
    if category.save
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      category.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @category = category
      render :edit, layout: false
    end
  end

  def edit
    @category = Category.find(params[:id])
    @cate = Category.where("code LIKE '__' ")
    @subcate = Category.where("code LIKE '____' ")
    @action = 'edit'
    render layout: false
  end

  def destroy
    category = Category.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => category
    #redirect_to :action => :index, :task => 'deleted'
  end

  def get_subcategory_form_category
    @subcategories = Category.where("code LIKE ?", params[:category_code]+"__")
    render json: {:subcategories => @subcategories}  
  end

  def get_specific_from_subcategory
    @specific = Category.where("code LIKE ?", params[:subcategory_code]+"__")
    render json: {:specifics => @specific}
  end  

  private
  def category_parameters
    params.require(:category).permit(:code, :name)
  end
end
