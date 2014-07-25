class GeneralExpenses::GeneralExpensesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @gexp = GeneralExpense.where("cost_center_id = "+get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def show
    @gexp = GeneralExpense.find(params[:id])
    render layout: false
  end

  def new
    @gexp = GeneralExpense.new
    @phase = Phase.where("code LIKE '____'")
    @action = 'new'
    render layout: false
  end

  def display_articles
    word = params[:q]
    article_hash = Array.new
    articles = GeneralExpense.getOwnArticles(word)
    articles.each do |art|
      article_hash << {'id' => art[0].to_s+'-'+art[3].to_s+'-'+art[1].to_s, 'code' => art[1], 'name' => art[2], 'symbol' => art[4]}
    end
    render json: {:articles => article_hash}
  end

  def create
    flash[:error] = nil
    gexp = GeneralExpense.new(gexp_parameters)
    gexp.cost_center_id = get_company_cost_center('cost_center').to_s
    if gexp.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      gexp.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @gexp = gexp
      render :new, layout: false 
    end
  end

  def edit
    @gexp = GeneralExpense.find(params[:id])
    @phase = Phase.where("code LIKE '____'")
    @reg_n = ((Time.now.to_f)*100).to_i
    @action = 'edit'
    render layout: false
  end

  def update
    gexp = GeneralExpense.find(params[:id])
    if gexp.update_attributes(gexp_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      gexp.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @gexp = gexp
      render :edit, layout: false
    end
  end

  def destroy
    gexp = GeneralExpense.destroy(params[:id])
    render :json => gexp
  end

  def add_concept
    @reg_n = ((Time.now.to_f)*100).to_i
    article = params[:article_id].split('-')
    @article = Article.find(article[0])
    @type = params[:type]
    render(partial: 'concepts', :layout => false)
  end

  private
  def gexp_parameters
    params.require(:general_expense).permit(:phase_id, :cost_center_id, 
      general_expense_details_attributes: [
        :id, 
        :general_expense_id, 
        :type_article,
        :article_id,
        :people,
        :participation,
        :time,
        :salary,
        :parcial,
        :amount,
        :cost,
        :depreciation,
        :useful_life,
        :price,
        :_destroy
      ])
  end
end