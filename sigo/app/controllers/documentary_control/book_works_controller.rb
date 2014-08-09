class DocumentaryControl::BookWorksController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @type_book = TypeOfBookWork.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def show
    @book = BookWork.find(params[:id])
    render layout: false
  end

  def new
    @cost_center = get_company_cost_center('cost_center')
    @type_book = TypeOfBookWork.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    @book = BookWork.new
    render layout: false
  end

  def create
    flash[:error] = nil
    book = BookWork.new(book_parameters)
    book.cost_center_id = get_company_cost_center('cost_center')
    if book.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      book.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @book = book
      render :new, layout: false 
    end
  end

  def edit
    @book = BookWork.find(params[:id])
    @cost_center = get_company_cost_center('cost_center')
    @type_book = TypeOfBookWork.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    @action = 'edit'
    render layout: false
  end

  def update
    book = BookWork.find(params[:id])
    if book.update_attributes(book_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      book.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @book = book
      render :edit, layout: false
    end
  end

  def destroy
    book = BookWork.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => book
  end

  def book_works
    word = params[:wordtosearch]
    @book = BookWork.where('name LIKE "%'+word.to_s+'%" OR description LIKE "%'+word.to_s+'%" AND cost_center_id = ?', get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  private
  def book_parameters
    params.require(:book_work).permit(:name, :description, :document, :date, :type_of_book_work_id)
  end
end