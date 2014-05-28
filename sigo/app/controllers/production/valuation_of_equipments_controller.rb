class Production::ValuationOfEquipmentsController < ApplicationController
	def index
		@company = get_company_cost_center('company')
  	#@workingGroups = WorkingGroup.all
    @subcontractequipmentdetail = SubcontractEquipmentDetail.all
    render layout: false
	end
	def new
		@costCenter = CostCenter.new
		TypeEntity.where("name LIKE '%Proveedores%'").each do |executor|
	      @executors = executor.entities
	    end
		render layout: false
	end
	def get_report
    render(partial: 'report_table', :layout => false)
  end
end