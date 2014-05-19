load 'sqlserver/dbconnector.rb'
require 'thread'


class Itembywbs < ActiveRecord::Base
	belongs_to :item
	belongs_to :budget
	belongs_to :wbsitem
	belongs_to :itembybudget

	def get_fases
		#do_query(str_query, {url: "192.168.1.90", db_name: "BAGUA", })
	end
end
