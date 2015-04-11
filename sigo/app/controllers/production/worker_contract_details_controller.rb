class Production::WorkerContractDetailsController < ApplicationController
  def index
  end

  def show
  end

  def new
    @worker_id = params[:worker_id]
    @worker_concept = WorkerContractDetail.new
    @concepts_obrero=Concept.where("type_obrero like 'Fijo' AND status like '1'")
    @concepts_empleado=Concept.where("type_empleado like 'Fijo' AND status like '1'")
    @reg_n = Time.now.to_i
    @action = "new"
    render layout: false  
  end

  def create
    flag = true
    params[:regs_arr].split(',').each do |ra|
      workercontract = WorkerContractDetail.new
      workercontract.worker_id = params[:worker_contract_detail][ra]['worker_id']
      workercontract.concept_id = params[:worker_contract_detail][ra]['concept_id']
      workercontract.amount = params[:worker_contract_detail][ra]['amount']
      if !workercontract.save
        flag = false
        workercontract.errors.messages.each do |attribute, error|
          flash[:error] =  flash[:error].to_s + error.to_s + "  "
        end
        render :new, layout: false        
      end
    end
    if flag
      redirect_to :controller => :workers, :action => :index
    end    
  end

  def edit
    @worker_id = params[:worker_id]
    @worker_concept = WorkerContractDetail.where("worker_id = " + @worker_id.to_s).first
    @worker_concept_d = WorkerContractDetail.where("worker_id = " + @worker_id.to_s)
    @concepts_obrero=Concept.where("type_obrero like 'Fijo' AND status like '1'")
    @concepts_empleado=Concept.where("type_empleado like 'Fijo' AND status like '1'")
    @reg_n = Time.now.to_i
    @action = "edit"
    render layout: false
  end

  def update
    flag = true
    params[:regs_arr].split(',').each do |ra|
      workercontract = WorkerContractDetail.find(params[:worker_contract_detail][ra]['id'])
      if !workercontract.update_attributes(:worker_id => params[:worker_contract_detail][ra]['worker_id'], :concept_id => params[:worker_contract_detail][ra]['concept_id'], :amount=> params[:worker_contract_detail][ra]['amount'])
        flag = false
        workercontract.errors.messages.each do |attribute, error|
          flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
        end
        # Load new()
        @worker_concept = WorkerContractDetail.new
        render :edit, layout: false, :worker_id => params[:worker_contract_detail][ra]['worker_id']
      end    
    end
    if flag
      redirect_to :controller => :workers, :action => :index
    end      
  end

  def destroy
  end

  def concept_workers
    @worker_id = @worker_id = params[:id]
    concept_worker = WorkerContractDetail.where("worker_id = " + @worker_id.to_s)
    if concept_worker.count > 1
      redirect_to :action => :edit, :worker_id => @worker_id
    else
      redirect_to :action => :new, :worker_id => @worker_id
    end
  end

  private
  def worker_contract_details_parameters
    params.require(:worker_contract_detail).permit(:worker_id, :concept_id, :amount)
  end

end
