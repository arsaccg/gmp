class Production::CategoryOfWorkersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]

  def index
    @article = TypeOfArticle.find_by_code('01').articles.first
    @company = get_company_cost_center('company')
    @categoryOfWorker = CategoryOfWorker.all
    render layout: false
  end

  def show
    @categoryOfWorker = CategoryOfWorker.all
    render layout: false
  end

  def new
    @categoryOfWorker = CategoryOfWorker.new
    @subgroups = Category.distinct.select(:id).select(:code).select(:name).where("code LIKE '71__'")
    @concept_earnings = Concept.where(:type_concept => 'Fijo').where(:status => 1).where("code LIKE '1%'")
    @concept_discounts = Concept.where(:type_concept => 'Fijo').where(:status => 1).where("code LIKE '2%'")
    @action = 'new'
    @reg_n = ((Time.now.to_f)*100).to_i
    render layout: false
  end

  def create
  end

  def edit
    @categoryOfWorker = CategoryOfWorker.find(params[:id])
    @subgroups = Category.distinct.select(:id).select(:code).select(:name).where("code LIKE '71__'")
    @concept_earnings = Concept.where(:type_concept => 'Fijo').where(:status => 1).where("code LIKE '1%'")
    @concept_discounts = Concept.where(:type_concept => 'Fijo').where(:status => 1).where("code LIKE '2%'")
    @action = 'edit'
    @reg_n = ((Time.now.to_f)*100).to_i
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
    params.require(:category_of_worker).permit(:name, :category_id, :article_id, :normal_price, :he_60_price, :he_100_price)
  end
end
