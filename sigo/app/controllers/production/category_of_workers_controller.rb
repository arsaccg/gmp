class Production::CategoryOfWorkersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]

  def index
    @article = TypeOfArticle.find_by_code('01').articles.first
    @company = get_company_cost_center('cost_center')
    @categoryOfWorker = CategoryOfWorker.where(:cost_center_id => @company).order(' category_of_workers.id  DESC').group(:category_id)
    render layout: false
  end

  def show
    @categoryOfWorker = CategoryOfWorker.all
    render layout: false
  end

  def new
    @categoryOfWorker = CategoryOfWorker.new
    @cc = get_company_cost_center('cost_center')
    @today = Time.now.to_date.strftime('%Y-%m-%d')
    @subgroups = Category.distinct.select(:id).select(:code).select(:name).where("code LIKE '71__'")
    @concept_earnings = Concept.where(:type_obrero => 'Fijo').where(:status => 1).where("code LIKE '1%'")
    @concept_discounts = Concept.where(:type_obrero => 'Fijo').where(:status => 1).where("code LIKE '2%'")
    @cc = get_company_cost_center('cost_center')
    @action = 'new'
    @semanas = ActiveRecord::Base.connection.execute("
      SELECT wc . * 
      FROM weeks_for_cost_center_" + get_company_cost_center('cost_center').to_s+" wc")
    render layout: false
  end

  def get_info_per_week
    categoryOfWorker = CategoryOfWorker.where("week_id = "+params[:week].to_s+" AND category_id = "+params[:cat].to_s+ " AND cost_center_id = "+ get_company_cost_center('cost_center').to_s).first
    ingresos = Array.new
    descuentos = Array.new
    reg = ((Time.now.to_f)*100).to_i
    if !categoryOfWorker.nil?
      category = {'id'=>categoryOfWorker.id , 'normal_price' => categoryOfWorker.normal_price, 'he_60_price' => categoryOfWorker.he_60_price, 'he_100_price'=>categoryOfWorker.he_100_price}
      categoryOfWorker.category_of_workers_concepts.each do |cow|
        if cow.concept_code[0] == '1'
          ingresos << {'id' => cow.id, 'name'=> Concept.find(cow.concept_id).name, 'category_of_worker_id'=>cow.category_of_worker_id ,'concept_id'=> cow.concept_id, 'amount'=>cow.amount, 'type_concept'=>cow.type_concept, 'concept_code'=>cow.concept_code, 'reg'=>reg.to_s}
        else
          descuentos << {'id' => cow.id, 'name'=> Concept.find(cow.concept_id).name, 'category_of_worker_id'=>cow.category_of_worker_id ,'concept_id'=> cow.concept_id, 'amount'=>cow.amount, 'type_concept'=>cow.type_concept, 'concept_code'=>cow.concept_code, 'reg'=>reg.to_s}
        end
        reg+=1
      end
    else
      category = {'normal_price' => "", 'he_60_price' => "", 'he_100_price'=>""}
      Concept.where(:type_obrero => 'Fijo').where(:status => 1).where("code LIKE '1%'").each do |ing|
        ingresos << {'id' => nil, 'name'=>ing.name, 'category_of_worker_id'=>nil ,'concept_id'=> ing.id, 'amount'=>0, 'type_concept'=>'Fijo', 'concept_code'=>ing.code, 'reg'=>reg.to_s}        
        reg+=1
      end

      Concept.where(:type_obrero => 'Fijo').where(:status => 1).where("code LIKE '2%'").each do |des|
        descuentos << {'id' => nil, 'name'=>des.name, 'category_of_worker_id'=>nil ,'concept_id'=> des.id, 'amount'=>0, 'type_concept'=>'Fijo', 'concept_code'=>des.code, 'reg'=>reg.to_s}
        reg+=1
      end
    end
    render json: {:category => category, :ingresos => ingresos, :descuentos => descuentos}
  end

  def create
    @categoryOfWorker = CategoryOfWorker.new(category_worker_parameters)
    if @categoryOfWorker.save
      flash[:notice] = "Se ha creado correctamente la nueva orden de compra."
      redirect_to :action => :index
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to :action => :index
    end
  end

  def edit
    @categoryOfWorker = CategoryOfWorker.find(params[:id])
    @today = Time.now.to_date.strftime('%Y-%m-%d')
    @subgroups = Category.distinct.select(:id).select(:code).select(:name).where("code LIKE '71__'")
    @semanas = ActiveRecord::Base.connection.execute("
      SELECT wc . * 
      FROM weeks_for_cost_center_" + get_company_cost_center('cost_center').to_s+" wc")
    @concept_earnings = @categoryOfWorker.category_of_workers_concepts.where(:type_concept => 'Fijo').where("concept_code LIKE '1%'")
    @concept_discounts = @categoryOfWorker.category_of_workers_concepts.where(:type_concept => 'Fijo').where("concept_code LIKE '2%'")
    @cc = get_company_cost_center('cost_center')
    @action = 'edit'
    @reg_n = ((Time.now.to_f)*100).to_i
    render layout: false
  end

  def update
    if params[:category_of_worker]['id'] != ''
      categoryOfWorker = CategoryOfWorker.find(params[:category_of_worker]['id'])
      categoryOfWorker.cost_center_id = get_company_cost_center('cost_center')
      flag = categoryOfWorker.update_attributes(category_worker_parameters)
    else
      categoryOfWorker = CategoryOfWorker.new(category_worker_parameters)
      categoryOfWorker.cost_center_id = get_company_cost_center('cost_center')
      flag = categoryOfWorker.save
    end

    if flag
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
    params.require(:category_of_worker).permit(
      :id,
      :week_id,
      :name, 
      :category_id, 
      :normal_price, 
      :he_60_price, 
      :he_100_price, 
      category_of_workers_concepts_attributes: [
        :id,
        :category_of_worker_id,
        :concept_id,
        :type_concept,
        :concept_code,
        :amount,
        :_destroy
      ]
    )
  end
end
