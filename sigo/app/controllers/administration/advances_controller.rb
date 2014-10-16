class Administration::AdvancesController < ApplicationController
	#before_filter :authorize_manager
  	before_filter :authenticate_user!
  	protect_from_forgery with: :null_session, :only => [:destroy, :delete]
	# ESTO PERTENECE A TOBI!!!!
	def index
		@advances = Advance.where(:cost_center_id => get_company_cost_center('cost_center'))
		render :index, :layout => false
	end

	def new
		@advance = Advance.new
		@advance.cost_center_id = get_company_cost_center('cost_center')
		render :new, :layout => false
	end

	def show
		@advance = Advance.find(params[:id])
		render :show, :layout => false
	end

	def update
		@advance = Advance.find(params[:id])
	    @advance.update_attributes(advances_parameters)
		redirect_to :action => :index
	end

	def create
		@advance = Advance.new(advances_parameters)
		@advance.cost_center_id = get_company_cost_center('cost_center')
		@advance.save

		redirect_to :action => :index
	end

	def edit
		@advance = Advance.find(params[:id])
		@action_label = "Editar Adelanto"
		render :edit, :layout => false
	end

	def destroy
		@advance = Advance.find(params[:id])
	    @advance.destroy

	    @advances = Advance.where(:cost_center_id => get_company_cost_center('cost_center'))
		render :index, :layout => false
	end

	private
	def advances_parameters
		params.require(:advance).permit(:advance_type, :advance_number, :advance_direct_cost_percent, :amount)
	end
end
