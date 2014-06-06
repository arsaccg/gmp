class Administration::ChargesController < ApplicationController
	before_filter :authorize_manager
	
	def index
		@charges = Charge.where(:invoice_id => params[:invoice_id])
		@invoice_id = params[:invoice_id]
		render :index, :layout => false
	end

	def new
		@invoices = Invoice.find(params[:invoice_id])
		@action_label = "Registrar Cobro"
		@charge = Charge.new
		@charge.invoice_id = @invoices.id

		#sum = (@invoices.charges.sum('payment_amount') rescue 0)
		#if sum >= @invoices.amount
		#	@invoices.paid
		#end
		#@invoices.observations = sum
		#@invoices.save

		render :new, :layout => false
	end

	def show
		@charge = Charge.find(params[:id])
		render :show
	end

	def create
		@charge = Charge.new(charge_parameters)
		@charge.save

		@invoices = Invoice.find(params[:invoice_id])
		sum = @invoices.charges.sum('payment_amount')
		if sum >= @invoices.amount
			@invoices.paid
		end
		@invoices.observations = sum
		@invoices.save

		redirect_to :action => :index, invoice_id: @invoices.id

	end

	def edit
		@charge = Charge.find(params[:id])
		@action_label = "Guardar Cobro"
	end

	def update

	end


	private
	def charge_parameters
	  params.require(:charge).permit(:invoice_id, :amount, :charge_date, :payment_amount, :financial_agent_client, :financial_agent_destiny)
	end
end
