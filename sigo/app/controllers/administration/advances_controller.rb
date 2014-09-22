class Administration::AdvancesController < ApplicationController
	#before_filter :authorize_manager
  	before_filter :authenticate_user!
	# ESTO PERTENECE A TOBI!!!!
	def index
		@advances = Advance.where(:cost_center_id => params[:project_id])
		render :index, :layout => false
	end

	def new
		@advance = Advance.new
		@advance.cost_center_id = params[:project_id]
		render :new, :layout => false
	end

	def show
		@advance = Advance.find(params[:id])
		render :show, :layout => false
	end

	def update
		@advance = Advance.find(params[:advance_id])
	    @advance.update_attributes(advances_parameters)
		redirect_to :action => :index
		
	end

	def create
		@advance = Advance.new(advances_parameters)
		@advance.cost_center_id = params[:project_id]
		@advance.save

		redirect_to :action => :index
	end

	def edit
		@advance = Advance.find(params[:id])
		@action_label = "Editar Adelanto"
		render :edit, :layout => false
	end

	def destroy
		@advance = Advance.destroy(params[:id])
		redirect_to :action => :index
	end

	private
	def advances_parameters
		params.require(:advance).permit(:advance_type, :advance_number, :advance_direct_cost_percent, :amount)
	end
end
