class Administration::ProvisionArticlesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @provision = Provision.all
    @documentProvision = DocumentProvision.first
    render layout: false
  end

  def new
    @provision = Provision.new
    @documentProvisions = DocumentProvision.all
    @suppliers = TypeEntity.find_by_preffix('P').entities
    @cost_center = get_company_cost_center("cost_center")
    render layout: false
  end

  def create
    provision = Provision.new(provisions_parameters)
    if provision.save
      provision_checked = Array.new
      total_amount = 0
      provision.provision_details.each do |detail|
        if !provision_checked.include? detail
          provision_checked << detail.order_detail_id
          ProvisionDetail.where('order_detail_id = ?', detail.order_detail_id).each do |details|
            total_amount += details.amount
          end
          Provision.update_received_order(total_amount, detail.order_detail_id, detail.type_of_order)
        end
      end
      flash[:notice] = "Se ha creado correctamente la nueva provision."
      redirect_to :action => :index
    else
      provision.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @provision = provision
      render :new, layout: false
    end
  end

  def edit
    @provision = Provision.find(params[:id])
    @documentProvisions = DocumentProvision.all
    @suppliers = TypeEntity.find_by_preffix('P').entities
    @action = 'edit'
    render layout: false
  end

  def update
    provision = Provision.find(params[:id])
    if provision.update_attributes(provisions_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      provision.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @provision = provision
      render :edit, layout: false
    end
  end

  def destroy
    provision = Provision.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => provision
  end

  #CUSTOM METHODS

  def puts_details_in_provision
    @data_orders = Array.new
    @data_article = params[:article_id].split('-')
    @amount = params[:amount]
    @reg_n = ((Time.now.to_f)*100).to_i
    @account_accountants = AccountAccountant.all
    @id_article = Article.find_idarticle_global_by_specific_idarticle(@data_article[0], get_company_cost_center("cost_center"))
    render(:partial => 'row_detail_provision', :layout => false)
  end

  private
  def provisions_parameters
    params.require(:provision).permit(
      :cost_center_id, 
      :entity_id, 
      :document_provision_id, 
      :number_document_provision, 
      :accounting_date, 
      :series, 
      :description,
      provision_details_attributes: [
        :id,
        :provision_id,
        :current_unit_price,
        :current_igv,
        :order_detail_id,
        :type_of_order,
        :account_accountant_id,
        :amount,
        :unit_price_igv,
        :_destroy
      ]
    )
  end

  def provision_direct_purchase_parameters
    params.require(:provision).permit(
      :cost_center_id, 
      :entity_id, 
      :document_provision_id, 
      :number_document_provision, 
      :accounting_date, 
      :series, 
      :description,
      provision_direct_purchase_details: [
        :id,
        :provision_id,
        :article_id,
        :sector_id,
        :phase_id,
        :amount,
        :price,
        :unit_price_before_igv,
        :igv,
        :quantity_igv,
        :discount_after,
        :discount_before,
        :description,
        :_destroy
      ]
    )
  end
end
