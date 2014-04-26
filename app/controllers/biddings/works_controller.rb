class Biddings::WorksController < ApplicationController

  def index
    @works = Work.all
    @financial_variables = Array.new
    FinancialVariable.where("name LIKE '%IPC%'").each do |fvar|
      @financial_variables = fvar
    end
    render layout: false
  end

  def show
    @work = Work.find(params[:id])
    @components = @work.components
    @work_partners = @work.work_partners
    @financial_variables = Array.new
    FinancialVariable.where("name LIKE '%IPC%'").each do |fvar|
      @financial_variables = fvar
    end
    render layout: false
  end

  def new
    @action = 'new'
    @work = Work.new
    @components = Component.all
    @moneys = Money.all
    @entities = Array.new
    @contractors = Array.new
    @financial_variables = Array.new
    FinancialVariable.where("name LIKE '%IPC%'").each do |fvar|
      @financial_variables = fvar
    end
    TypeEntity.where("name LIKE 'Clientes'").each do |tent|
      @entities << tent.entities
    end
    TypeEntity.where("name LIKE 'Contratistas'").each do |tent|
      @contractors << tent.entities
    end
    render layout: false
  end

  def create
    work = Work.new(work_params)
    if work.save
      flash[:notice] = "Se ha creado correctamente la Obra."
      redirect_to :action => :index
    else
      work.errors.messages.each do |attribute, error|
          puts error.to_s
          puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index
    end
  end

  def edit
    @action = 'edit'
    @work = Work.find(params[:id])
    @components = Component.all
    @moneys = Money.all
    @entities = Array.new
    @contractors = Array.new
    @financial_variables = Array.new
    FinancialVariable.where("name LIKE '%IPC%'").each do |fvar|
      @financial_variables = fvar
    end
    TypeEntity.where("name LIKE 'Clientes'").each do |tent|
      @entities << tent.entities
    end
    TypeEntity.where("name LIKE 'Contratistas'").each do |tent|
      @contractors << tent.entities
    end
    render layout: false
  end

  def update
    work = Work.find(params[:id])
    if work.update_attributes(work_params)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      work.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @work = work
      render :edit, layout: false
    end
  end

  def destroy
    work = Work.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => work
  end

  # Upload Multiple File
  def more_documents
    @type_doc = params[:type_doc]
    @reg = Time.now.to_i
    render layout: false
  end

  def get_components_by_speciality
    @components = Array.new
    Component.where("specialty = (?)",params[:specialty]).each do |comspe|
      @components << comspe
    end 
    render json: {:components => @components}  
  end

  private
  def work_params
    params.require(:work).permit(
      :compliance_work, 
      :amount_contract_of_inquiry, 
      :amount_settlement_of_inquiry, 
      :amount_contract_of_is, 
      :amount_settlement_of_is, 
      :number_of_settlement, 
      :exchange_of_rate, 
      :money_id, 
      {:work_partner_ids => []}, 
      :budget, 
      :arbitration, 
      :start_date_of_inquiry, 
      :end_date_of_inquiry, 
      :integrated_bases, 
      :procurement_system, 
      :purpose_of_contract, 
      :date_signature_of_contract, 
      :start_date_of_work, 
      :real_end_date_of_work, 
      :date_of_receipt_of_work, 
      :settlement_date, 
      :specialty, 
      :name, 
      :entity_id, 
      :participation_of_arsac, 
      :contractor_id, 
      :amount_of_contract, 
      :amount_of_settlement, 
      :ipc_settlement, 
      :testimony_of_consortium, 
      :contract, 
      :reception_certificate, 
      :settlement_of_work, 
      {:component_ids => []},
      arbitration_documents_attributes: [
        :id, :work_id, :attachment, :_destroy
      ],
      contract_documents_attributes: [
        :id, :work_id, :attachment, :_destroy
      ],
      integrated_bases_documents_attributes: [
        :id, :work_id, :attachment, :_destroy
      ],
      testimony_of_consortium_documents_attributes: [
        :id, :work_id, :attachment, :_destroy
      ],
      invoice_documents_attributes: [
        :id, :work_id, :attachment, :_destroy
      ]
    )
  end
end
