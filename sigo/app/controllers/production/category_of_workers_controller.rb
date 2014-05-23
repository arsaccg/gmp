class Production::CategoryOfWorkersController < ApplicationController
  def index
    @article = TypeOfArticle.find_by_code('01').articles.first
    @company = params[:company_id]
    @categoryOfWorker = CategoryOfWorker.all
    render layout: false
  end

  def show
    #@categoryOfWorker = CategoryOfWorker.find(params[:id])
    render layout: false
  end

  def new
    render layout: false
  end

  def create
  end

  def edit
    @categoryOfWorker = CategoryOfWorker.find(params[:id])
    @company = params[:company_id]
    render layout: false
  end

  def update
    categoryOfWorker = CategoryOfWorker.find(params[:id])
    if categoryOfWorker.update_attributes(category_worker_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      categoryOfWorker.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @categoryOfWorker = categoryOfWorker
      render :edit, layout: false
    end
  end

  def destroy
  end

  private
  def category_worker_parameters
    params.require(:category_of_worker).permit(:article_id, :normal_price, :he_60_price, :he_100_price)
  end
end
