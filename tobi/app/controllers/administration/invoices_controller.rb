class Administration::InvoicesController < ApplicationController
	before_filter :authorize_manager

	def index
		@budget_id = params[:budget_id]
		@budget = Budget.find(@budget_id)
		@valorizations = @budget.valorizations
		render :index, :layout => false
	end

	def new
		@valorization = Valorization.find(params[:valorization_id])
		@action = params[:actionForm]
		@action_label = "Registrar Factura"
		@invoice = Invoice.new
		@invoice.valorization_id = @valorization.id
		render :new, :layout => false
	end

	def show
		@invoice = Invoice.find(params[:id])
		render :show
	end

	def create
		@invoice = Invoice.new(invoice_parameters)
		@invoice.status
		@budget_id = params[:budget_id]
		@invoice.save
		redirect_to :action => :index, :budget_id => @budget_id

	end

	def edit
		@invoice = Invoice.find(params[:id])
		@action = params[:actionForm]+'_'+params[:id]
		@action_label = "Guardar Factura"
		render :edit, :layout => false
	end

	def update
		@invoice = Invoice.find(params[:invoice_id])
	    @invoice.update_attributes(invoice_parameters)
		redirect_to :action => :index, :budget_id => @invoice.valorization.budget.id, :layout => false
	end

	def destroy
		@invoice = Invoice.destroy(params[:invoice_id])
		redirect_to :action => :index, :budget_id => params[:budget_id], :layout => false
	end

	private
	def invoice_parameters
	  params.require(:invoice).permit(:valorization_id, :amount, :issue_date, :filing_date, :credit_note, :observations, :document_number)
	end

end
