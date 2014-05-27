class Production::EquipmentReportsController < ApplicationController
	def index
		@company = get_company_cost_center('company')
  	@workingGroups = WorkingGroup.all
    @article = Article.where("type_of_article_id = 3")
    render layout: false
	end
end
