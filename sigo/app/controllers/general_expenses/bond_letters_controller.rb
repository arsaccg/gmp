class GeneralExpenses::BondLettersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @letters = BondLetter.where("cost_center_id = "+params[:cc].to_s)
    @cc = CostCenter.find(params[:cc])
    @total_amount = 0
    @total_retention = 0
    @total_cost = 0
    @letters.each do |bld|
      if bld.bond_letter_details.count > 0
        @total_amount += bld.bond_letter_details.last.amount.to_f
        @total_retention += bld.bond_letter_details.last.retention_amount.to_f
        @total_cost += ActiveRecord::Base.connection.execute("
            SELECT sum(issuance_cost)
            FROM bond_letter_details
            WHERE bond_letter_details.bond_letter_id = " + bld.id.to_s
          ).first[0].to_f
      end
    end
    render layout: false
  end

  def show
    render layout: false
  end

  def new
    @cc = CostCenter.find(params[:cc])
    @letters = BondLetter.new
    @issuer = TypeEntity.find_by_preffix("P").entities
    @receptor = TypeEntity.find_by_preffix("C").entities
    @receptor = @receptor + @issuer
    render layout: false  
  end

  def new_bond_letter_detail
    @cc = CostCenter.find(params[:cc])
    @bl = params[:bl]
    @letter_detail = BondLetterDetail.new()
    render layout: false
  end

  def create
    flash[:error] = nil
    letter = BondLetter.new(letter_params)
    if letter.save
      letter.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
    end
    render :json => letter
  end

  def create_bond_letter_detail
    flash[:error] = nil
    letter = BondLetterDetail.new(letter_details_params)
    if letter.save
      letter.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
    end
    render :json => letter
  end  

  def edit
    @cc = CostCenter.find(params[:cc])
    @letter = BondLetter.find(params[:id])
    @action = 'edit'
    @issuer = TypeEntity.find_by_preffix("P").entities
    @receptor = TypeEntity.find_by_preffix("C").entities
    @receptor = @receptor + @issuer    
    render layout: false    
  end

  def edit_bond_letter_detail
    @cc = CostCenter.find(params[:cc])
    @letter_detail = BondLetterDetail.find(params[:id])
    @action = 'edit'
    @bl = params[:bl]
    render layout: false    
  end  

  def update
    letter = BondLetter.find(params[:id])
    if letter.update_attributes(letter_params)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      render :json => letter
    else
      con.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @letter = letter
      render :edit, layout: false, :cc => letter.cost_center_id
    end    
  end

  def update_bond_letter_detail
    letter = BondLetterDetail.find(params[:id])
    if letter.update_attributes(letter_details_params)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      render :json => letter
    else
      con.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      render :json => letter
    end    
  end  

  def display_issuer
    p params[:element]
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

  def display_receptor
    p params[:element]
    if params[:element].nil?
      word = params[:q]
    else
      word = params[:element]
    end
    article_hash = Array.new
    @name = get_company_cost_center('cost_center')
    type_ent = TypeEntity.find_by_preffix('P').id
    receptor = TypeEntity.find_by_preffix("C").id
    if !params[:element].nil?
      articles = ActiveRecord::Base.connection.execute("
            SELECT ent.id, ent.name, ent.ruc
            FROM entities ent, entities_type_entities ete
            WHERE ete.type_entity_id IN ("+type_ent.to_s+","+receptor.to_s+")
            AND ete.entity_id = ent.id
            AND ent.id = " + word.to_s
          )      
    else
      articles = ActiveRecord::Base.connection.execute("
            SELECT ent.id, ent.name, ent.ruc
            FROM entities ent, entities_type_entities ete
            WHERE ete.type_entity_id IN ("+type_ent.to_s+","+receptor.to_s+")
            AND ete.entity_id = ent.id
            AND (ent.id = '%"+word.to_s+"%' OR ent.name LIKE '%" + word.to_s + "%' OR ent.ruc LIKE '%" + word.to_s + "%')"
          )
    end
    articles.each do |art|
      article_hash << {'id' => art[0].to_s, 'code' => art[2], 'name' => art[1]}
    end
    render json: {:articles => article_hash}
  end

  def destroy
    loan = BondLetter.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => loan
  end

  def show_summary_table
    @cc = CostCenter.find(params[:cc])
    @letter = BondLetter.find(params[:id])
    render(:partial => 'table_deliveries', :layout => false)
  end  

  def type_advances
    @advances = Advance.where(cost_center_id: params[:cost_center])
    render json: {:advances => @advances}
  end

  private
  def letter_params
    params.require(:bond_letter).permit(:cost_center_id, :issuer_entity_id, :receptor_entity_id, :advance_id, :status, :concept)
  end
  def letter_details_params
    params.require(:bond_letter_detail).permit(:bond_letter_id, :code, :issu_date, :expiration_date, :amount, :issuance_cost, :retention_amount, :retention_percentage, :rate)
  end    
end