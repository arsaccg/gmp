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
    @SubCategories = Subcategory.all
    @Categories = Category.all
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
    @subcategory_specific = Subcategory.where("code LIKE ?", "#{@article.code.first(6).from(2)}")
    @subcategory_specific.each do |sub|
      @subcategory_specific = sub.code
    end


    @Specifics = Specific.find(params[:id])
    @SubCategories = Subcategory.all
    @Categories = Category.all
    @action = 'edit'
    render layout: false
  end

  def update
    specific = Specific.find(params[:id])
    specific.subcategory_id = params[:specific]['subcategory_id'].to_s
    specific.category_id = params[:specific]['category_id'].to_s
    specific.code = params[:extrafield]['first_code'].to_s + params[:specific]['code'].to_s
    specific.name = params[:specific]['name'].to_s
    if specific.save #update_attributes(subcategory_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to url_for(:controller => :categories, :action => :index)
    else
      specific.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end

      @subcategory_specific = Subcategory.where("code LIKE ?", "#{@article.code.first(6).from(2)}")
      @subcategory_specific.each do |sub|
      @subcategory_specific = sub.code
    end
      # Load new()
      @Specifics = specific
      @SubCategories = Subcategory.all
      @Categories = Category.all
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

  def get_specific_from_subcategory
    @specific = Specific.where("subcategory_id = ?", params[:subcategory_id])
    render json: {:specifics => @specific}
  end  
  
  private
  def specific_parameters
    params.require(:specific).permit(:subcategory_id, :code, :name)
  end
end
