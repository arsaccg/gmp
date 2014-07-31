class Administration::ProvisionArticlesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    @provision = Provision.where('order_id IS NULL')
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

    FinancialVariable.where("name LIKE '%IGV%'").each do |val|
      @igv = val.value.to_f+1
    end

    render layout: false
  end

  def edit
    @provision = Provision.find(params[:id])
    @documentProvisions = DocumentProvision.all
    @suppliers = TypeEntity.find_by_preffix('P').entities

    FinancialVariable.where("name LIKE '%IGV%'").each do |val|
      @igv= val.value.to_f+1
    end

    @action = 'edit'
    render layout: false
  end

  def destroy
    provision = Provision.find(params[:id])
    provision.provision_direct_purchase_details.destroy_all

  end

  #CUSTOM METHODS

  def puts_details_in_provision
    @data_orders = Array.new
    params_article = params[:article_id].split('-')
    @amount = params[:amount]
    @reg_n = ((Time.now.to_f)*100).to_i
    @account_accountants = AccountAccountant.all
    @sectors = Sector.where("code LIKE '__' ")
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center')).sort
    data_article = Article.find_idarticle_global_by_specific_idarticle(params_article[0], get_company_cost_center("cost_center"))

    @id_article = data_article[1]
    @name_article = data_article[0]
    @unit_of_measurement = data_article[2]

    render(:partial => 'row_detail_provision', :layout => false)
  end

end
