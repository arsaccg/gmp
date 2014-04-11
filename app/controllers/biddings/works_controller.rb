class Biddings::WorksController < ApplicationController
  def index
    @works = Work.all
    render layout: false
  end

  def show
    @work = Work.find(params[:id])
    render layout: false
  end

  def new
    @work = Work.new
    @components = Component.all
    @entities = Array.new
    TypeEntity.where("id IN (1,5)").each do |tent|
      @entities << tent.entities
    end
    render layout: false
  end

  def create
    work = Work.new(work_params)
    if work.save
      flash[:notice] = "Se ha creado correctamente el articulo."
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
    @work = Work.find(params[:id])
    @components = Component.all
    @entities = Array.new
    TypeEntity.where("id IN (1,5)").each do |tent|
      @entities << tent.entities
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
  end

  private
  def work_params
    params.require(:work).permit(:date_signature_of_contract, :start_date_of_work, :real_end_date_of_work, :date_of_receipt_of_work, :settlement_date, :specialty, :name, :entity_id, :participation_of_arsac, :contractor, :amount_of_contract, :amount_of_settlement, :ipc_settlement, :testimony_of_consortium, :contract, :reception_certificate, :settlement_of_work)
  end
end
