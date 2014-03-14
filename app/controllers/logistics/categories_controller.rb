class Logistics::CategoriesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    flash[:error] = nil
    @categories = Category.all
    render layout: false
  end

  def show
  end

  def new
    @category = Category.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    category = Category.new(category_parameters)
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
    if category.update_attributes(category_parameters)
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
