class Administration::ProvisionArticlesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    @provision = Provision.where('order_id IS NULL AND cost_center_id = ?', get_company_cost_center('cost_center'))
    @documentProvision = DocumentProvision.first
    render layout: false
  end

  def show
    @provision = Provision.find(params[:id])
    render layout: false
  end

  def new
    @provision = Provision.new
    @documentProvisions = DocumentProvision.all
    @suppliers = TypeEntity.find_by_preffix('P').entities
    @cost_center = get_company_cost_center("cost_center")
    @money = Money.all
    FinancialVariable.where("name LIKE '%IGV%'").each do |val|
      @igv = val.value.to_f+1
    end

    render layout: false
  end

  def display_proveedor
    if params[:element].nil?
      word = params[:q]
    else
      word = params[:element]
    end
    article_hash = Array.new
    @name = get_company_cost_center('cost_center')
    type_ent = TypeEntity.find_by_preffix('P').id
    if !params[:element].nil?
      articles = ActiveRecord::Base.connection.execute("
            SELECT ent.id, ent.name, ent.ruc
            FROM entities ent, entities_type_entities ete
            WHERE ete.type_entity_id = "+type_ent.to_s+"
            AND ete.entity_id = ent.id
            AND ent.id = " + word.to_s
          )      
    else
      articles = ActiveRecord::Base.connection.execute("
            SELECT ent.id, ent.name, ent.ruc
            FROM entities ent, entities_type_entities ete
            WHERE ete.type_entity_id = "+type_ent.to_s+"
            AND ete.entity_id = ent.id
            AND (ent.id = '%"+word.to_s+"%' OR ent.name LIKE '%" + word.to_s + "%' OR ent.ruc LIKE '%" + word.to_s + "%')"
          )
    end
    articles.each do |art|
      article_hash << {'id' => art[0].to_s, 'code' => art[2], 'name' => art[1]}
    end
    render json: {:articles => article_hash}
  end
  
  def edit
    @provision = Provision.find(params[:id])
    @documentProvisions = DocumentProvision.all
    @suppliers = TypeEntity.find_by_preffix('P').entities
    @sectors = Sector.where("code LIKE '__' ")
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center')).sort
    FinancialVariable.where("name LIKE '%IGV%'").each do |val|
      @igv= val.value.to_f+1
    end
    @money = Money.all
    @account_accountants = AccountAccountant.where("code LIKE  '_______'")
    @reg_n = ((Time.now.to_f)*100).to_i
    @extra_calculations = ExtraCalculation.all
    @action = 'edit'
    @cost_center = get_company_cost_center('cost_center')
    render layout: false
  end

  def destroy
    provision = Provision.find(params[:id])
    provision.provision_direct_purchase_details.destroy_all
    provision_destroyed = Provision.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => provision

  end

  #CUSTOM METHODS
  def add_modal_extra_operations
    @modal = params[:id_m]
    @extra_calculations = ExtraCalculation.all
    render(partial: 'extra_op', :layout => false)
  end

  def add_more_row_form_extra_op
    @reg_n = ((Time.now.to_f)*100).to_i
    @concept = params[:concept ]
    @type = params[:type]
    @value = params[:value]
    @apply = params[:apply]
    @operation = params[:operation]

    @reg_main = params[:reg_n]
    @name_concept = params[:name_concept]
    @name_type = params[:name_type]
    @name_apply = params[:name_apply]
    render(partial: 'extra_op_form', :layout => false)
  end

  def puts_details_in_provision
    @action = 'direct'
    @data_orders = Array.new
    params_article = params[:article_id].split('-')
    @amount = params[:amount]
    @reg_n = ((Time.now.to_f)*100).to_i
    @account_accountants = AccountAccountant.where("code LIKE  '_______'")
    @sectors = Sector.where("code LIKE '__' ")
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center')).sort
    data_article = Article.find_idarticle_global_by_specific_idarticle(params_article[0], get_company_cost_center("cost_center"))
    @cc = get_company_cost_center('cost_center')
    @id_article = data_article[1]
    @name_article = data_article[0]
    @unit_of_measurement = data_article[2]
    render(:partial => 'row_detail_provision', :layout => false)
  end

  def account3l
    if params[:element].nil?
      word = params[:q]
    else
      word = params[:element]
    end       
    article_hash = Array.new
    if !params[:element].nil?    
      articles = ActiveRecord::Base.connection.execute("
        SELECT id, code
        FROM account_accountants
        WHERE id = #{word}"
      )
    else
      articles = ActiveRecord::Base.connection.execute("
        SELECT id, code
        FROM account_accountants
        WHERE code LIKE  '_______'
        AND code LIKE '%#{word}%'"
      )
    end
    articles.each do |art|
      article_hash << {'id' => art[0].to_s, 'code' => art[1]}
    end
    render json: {:articles => article_hash}
  end

  def phases3l
    if params[:element].nil?
      word = params[:q]
    else
      word = params[:element]
    end    
    article_hash = Array.new
    name = get_company_cost_center('cost_center')
    if !params[:element].nil?
      articles = ActiveRecord::Base.connection.execute("
        SELECT DISTINCT p.id, p.code 
        FROM wbsitems w, phases p, general_expenses ge 
        WHERE (w.cost_center_id = #{name} AND w.phase_id = p.id OR ge.phase_id = p.id) 
        AND p.id = #{word}
        ORDER BY p.code ASC"
      )
    else
      articles = ActiveRecord::Base.connection.execute("
        SELECT DISTINCT p.id, p.code 
        FROM wbsitems w, phases p, general_expenses ge 
        WHERE (w.cost_center_id = #{name} AND w.phase_id = p.id OR ge.phase_id = p.id) 
        AND (p.code LIKE '%#{word}%' OR p.name LIKE '%#{word}%')
        ORDER BY p.code ASC"
      )
    end

    articles.each do |art|
      article_hash << {'id' => art[0].to_s, 'code' => art[1]}
    end
    render json: {:articles => article_hash}
  end

  def display_articles
    word = params[:q]
    article_hash = Array.new
    @cc_id = get_company_cost_center('cost_center')
    articles = Provision.getOwnArticles(word, @cc_id)
    articles.each do |art|
      article_hash << {'id' => art[0].to_s+'-'+art[3].to_s, 'code' => art[1], 'name' => art[2], 'symbol' => art[4]}
    end
    render json: {:articles => article_hash}    
  end

end
