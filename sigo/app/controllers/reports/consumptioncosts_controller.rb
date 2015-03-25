class Reports::ConsumptioncostsController < ApplicationController
  before_filter :authenticate_user!
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]  

  def index
  	@dates = Array.new
  	cost_center_detail_obj = CostCenter.find(get_company_cost_center('cost_center')).cost_center_detail
  	start_date = cost_center_detail_obj.start_date_of_work
  	end_date = start_date + cost_center_detail_obj.execution_term.days
  	start_date.upto(end_date) do |a|
  		@dates << [a.month, a.year]
  	end
  	@dates.uniq!

    # => Config
    @phase = Phase.select(:id).select(:name).select(:code).where("code LIKE '__'")

    @sector = Sector.select(:id).select(:name).select(:code).where("code LIKE '__'")
    @cc = get_company_cost_center("cost_center")
    @working_group = WorkingGroup.select(:id).select(:name)
    front_chief_ids = WorkingGroup.distinct.select(:front_chief_id).where("cost_center_id ="+@cc.to_s).map(&:front_chief_id)
    @front_chiefs = Worker.distinct.where(:id => front_chief_ids) # Jefes de Frentes
    # PositionWorker.find(1).workers
    master_builder_ids = WorkingGroup.distinct.select(:master_builder_id).where("cost_center_id ="+@cc.to_s).map(&:master_builder_id)
    @master_builders = Worker.distinct.where(:id => master_builder_ids) # Capatazes o Maestros de Obra
    # PositionWorker.find(2).workers
    executor_ids = Subcontract.distinct.select(:entity_id).where('entity_id <> 0').where("cost_center_id ="+@cc.to_s).map(&:entity_id)
    @executors = Entity.distinct.where(:id => executor_ids) # Exclude the Subcontract Default

    @groups = Category.select(:id).select(:name).select(:code).where("code LIKE '__'")

  	render layout: false
  end

  def consult
    @month = Date.parse(params[:date] + '-01').strftime('%B %Y')
  	cost_center_obj = CostCenter.find(get_company_cost_center('cost_center'))
  	@cost_center_str = cost_center_obj.company.name.to_s + ': ' + ' CC ' + cost_center_obj.code.to_s + ' - ' + cost_center_obj.name.to_s
  	@magic_result_ge = ConsumptionCost.apply_all_consult(cost_center_obj.id,Time.now.to_date.strftime("%m%Y"))
    @magic_result_gen_serv = ConsumptionCost.apply_all_gen_serv(cost_center_obj.id,Time.now.to_date.strftime("%m%Y"))
    @magic_result_dc = ConsumptionCost.apply_all_direct_cos(cost_center_obj.id, Time.now.to_date.strftime("%m%Y"))
  	render(partial: 'table', :layout => false)
  end

  def create_tables_missing
    cost_centers = CostCenter.all
    cost_centers.each do |cc|
      create_tables = ConsumptionCost.create_tables_new_costcenter(cc.id,cc.start_date,cc.end_date)
    end
    flash[:notice] = "Se han creado las tablas de los centros de costo."
    redirect_to :action => :index
  end

  def get_subphase
    type = Phase.find(params[:phase_id])
    subphase = Phase.where("code LIKE '" + type.code + "__'" )
    render json: {:subphase => subphase}  
  end

  def get_subsector
    type = Sector.find(params[:sector_id])
    subsector = Sector.where("code LIKE '" + type.code + "__' AND cost_center_id = " + get_company_cost_center('cost_center') )
    render json: {:subsector => subsector}  
  end

  def get_subgroup
    type = Category.find(params[:group_id])
    subgroup = Category.where("code LIKE '" + type.code + "__'")
    render json: {:subgroup => subgroup}  
  end

  def get_specific
    type = Category.find(params[:subgroup_id])
    specific = Category.where("code LIKE '" + type.code + "__'")
    render json: {:specific => specific}  
  end

  def get_art
    type = Category.find(params[:specific_id])
    article = Article.where("code LIKE '__" + type.code + "__'")
    render json: {:article => article}  
  end    


end
