class DocumentaryControl::TypeOfBookWorksController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @typeOfBook = TypeOfBookWork.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def new
    @typeOfBook = TypeOfBookWork.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    typeOfBook = TypeOfBookWork.new(typeOfBook_parameters)
    typeOfBook.cost_center_id = get_company_cost_center('cost_center')
    if typeOfBook.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      typeOfBook.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfBook = typeOfBook
      render :new, layout: false
    end
  end

  def edit
    @typeOfBook = TypeOfBookWork.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    typeOfBook = TypeOfBookWork.find(params[:id])
    typeOfBook.cost_center_id = get_company_cost_center('cost_center')
    if typeOfBook.update_attributes(typeOfBook_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      typeOfBook.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfBook = typeOfBook
      render :edit, layout: false
    end
  end

  def destroy
    typeOfBook = TypeOfBookWork.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => typeOfBook
  end

  private
  def typeOfBook_parameters
    params.require(:type_of_book_work).permit(:preffix, :name)
  end
end