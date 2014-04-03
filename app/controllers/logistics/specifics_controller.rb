class Logistics::SpecificsController < ApplicationController

  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
  end

  def show
    specific = Specific.find(params[:id])
    render :show
  end

  def new
    @Specifics = Specific.new
    @subcategories = Subcategory.all
    @categories = Category.all
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    specific = Specific.new(specific_parameters)
    specific.code = params[:extrafield]['first_code'].to_s + params[:specific]['code'].to_s

    if specific.save
      flash[:notice] = "Se ha creado correctamente el nuevo específico."
      redirect_to url_for(:controller => :categories, :action => :index)
    else
      specific.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @Specific = specific
      @SubCategories = Subcategory.all
      @Categories = Category.all
      render :new, layout: false
    end
  end

  def edit
    @Specifics = Specific.find(params[:id])
    # Categoria y Subcategoria especifica
    @subcategory_specific = @Specifics.subcategory
    @category_specific = @subcategory_specific.category

    @categories = Category.all
    @subcategories = @category_specific.subcategories
    @action = 'edit'
    render layout: false
  end

  def update
    specific = Specific.find(params[:id])
    specific.subcategory_id = params[:specific]['subcategory_id'].to_s
    specific.code = params[:extrafield]['first_code'].to_s + params[:specific]['code'].to_s
    specific.name = params[:specific]['name'].to_s
    if specific.save #update_attributes(subcategory_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to url_for(:controller => :categories, :action => :index)
    else
      specific.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end

      # Load new()
      @Specifics = specific
      @subcategory_specific = @Specifics.subcategory
      @category_specific = @subcategory_specific.category

      @categories = Category.all
      @subcategories = @category_specific.subcategories
      @action = 'edit'
      render :edit, layout: false
    end
  end

  def destroy
    specific = Specific.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente la sub-categoria seleccionado."
    render :json => specific
    #redirect_to url_for(:controller => :categories, :action => :index, :task => 'deleted')
  end

  def get_subcategory_form_category
    @subcategories = Subcategory.where("category_id = ?", params[:category_id])
    render json: {:subcategories => @subcategories}  
  end
  
  private
  def specific_parameters
    params.require(:specific).permit(:subcategory_id, :code, :name)
  end
end
