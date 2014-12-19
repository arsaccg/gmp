class Payrolls::ConceptsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @con = Concept.all
    render layout: false
  end

  def show
    @con = Concept.find(params[:id])
    render layout: false
  end

  def new
    @con = Concept.new
    @reg_n = ((Time.now.to_f)*100).to_i
    @condeTrab = Concept.where("code LIKE '2%'")
    @condeEmp = Concept.where("code LIKE '3%'")
    @date_week = Time.now.strftime('%Y-%m-%d')
    @cost_center = get_company_cost_center('cost_center')
    render layout: false
  end

  def create
    flash[:error] = nil
    con = Concept.new(con_parameters)
    con.status = 1
    con.company_id = get_company_cost_center('company')
    #con.concept_details.each do |ccd|
    #  ccd.status = 0
    #end
    con.code = params[:tipo].to_s + con.code.to_s
    con.token = '[' + params[:concept]['name'].downcase.parameterize.to_s + ']'
    if con.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      con.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @con = con
      render :new, layout: false 
    end
  end

  def edit
    @condeTrab = Concept.where("code LIKE '2%'")
    @condeEmp = Concept.where("code LIKE '3%'")
    @date_week = Time.now.strftime('%Y-%m-%d')
    @cost_center = get_company_cost_center('cost_center')

    @con = Concept.find(params[:id])
    ids = Array.new
    @reg_n = ((Time.now.to_f)*100).to_i
    ids << @con.id
    
    @con.concept_details.each do |co|
      ids << co.subconcept_id
    end
    
    ids = ids.join(',')
    @coned=@con.concept_details.where("status = 0")
    @conde = Concept.where("id NOT IN (" + ids.to_s + ")")
    
    @action = 'edit'
    render layout: false
  end

  def update
    con = Concept.find(params[:id])
    con.code = params[:tipo].to_s + con.code.to_s
    con.company_id = get_company_cost_center('company')
    con.token = '[' + params[:concept]['name'].downcase.parameterize.to_s + ']'
    if params[:check_type_worker_worker].nil?
      con.type_obrero = nil
    end
    if params[:check_type_worker_employee].nil?
      con.type_empleado = nil
    end
    if con.update_attributes(con_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      con.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @con = con
      render :edit, layout: false
    end
  end

  def destroy
    con = Concept.find(params[:id])
    ActiveRecord::Base.connection.execute("
          UPDATE concepts SET
          status = 0
          WHERE id = " + con.id.to_s + "
        ")
    ActiveRecord::Base.connection.execute("
          UPDATE concept_details SET
          status = 0
          WHERE concept_id = " + con.id.to_s + " AND status = 1
        ")
    render :json => con
  end

  def activate
    con = Concept.find(params[:id])
    ActiveRecord::Base.connection.execute("
          UPDATE concepts SET
          status = 1
          WHERE id = " + con.id.to_s + "
        ")
    ActiveRecord::Base.connection.execute("
          UPDATE concept_details SET
          status = 1
          WHERE concept_id = " + con.id.to_s + " AND status = 0
        ")
    redirect_to :action => :index
  end
    # CUSTOM METHODS

  def display_concepts
    word = params[:q]
    concepts_hash = Array.new
    concepts = Concept.where(:status => 1).where("code LIKE '1%' AND name LIKE '%#{word}%'")
    concepts.each do |concept|
      concepts_hash << { 'id' => concept.token, 'name' => '(' + concept.code.to_s + ') ' + concept.name }
    end
    render json: { :concepts => concepts_hash }
  end

  def add_subconcept
    @reg_n = ((Time.now.to_f)*100).to_i
    @subconcept = Concept.find(params[:subconcept])
    @category = params[:category].to_s
    render(partial: 'concept', :layout => false)
  end

  private
  def con_parameters
    params.require(:concept).permit(:name, :percentage, :amount, :top, :code, :type_obrero, :type_empleado, :company_id, 
      concept_details_attributes: [
        :id, 
        :concept_id, 
        :category, 
        :subconcept_id, 
        :status,
        :_destroy
      ],
      concept_valorizations_attributes: [
        :id,
        :concept_id,
        :date_week,
        :cost_center_id,
        :formula,
        :type_worker,
        :_destroy
      ]
    )
  end
end