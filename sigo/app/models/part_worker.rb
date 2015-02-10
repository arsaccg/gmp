class PartWorker < ActiveRecord::Base
  has_many :part_worker_details
  belongs_to :company
  accepts_nested_attributes_for :part_worker_details, :allow_destroy => true

  def self.get_part_workers(cost_center, display_length, pager_number, keyword = '')
  	result = Array.new
  	if keyword != '' && pager_number != 'NaN'
      part_workers = ActiveRecord::Base.connection.execute("
        SELECT pp.id, pp.number_part, pp.date_of_creation, pp.blockweekly
        FROM part_workers pp
        WHERE pp.cost_center_id = " + cost_center.to_s + " 
        AND (pp.number_part LIKE '%" + keyword + "%' OR pp.date_of_creation LIKE '%" + keyword + "%') 
        ORDER BY pp.number_part DESC 
        LIMIT " + display_length + " 
        OFFSET " + pager_number
      )
  	elsif pager_number != 'NaN'
      part_workers = ActiveRecord::Base.connection.execute("
        SELECT pp.id, pp.number_part, pp.date_of_creation, pp.blockweekly
        FROM part_workers pp
        WHERE pp.cost_center_id = " + cost_center.to_s + " 
        ORDER BY pp.number_part DESC 
        LIMIT " + display_length + " 
        OFFSET " + pager_number
      )
  	else
  	  part_workers = ActiveRecord::Base.connection.execute("
        SELECT pp.id, pp.number_part, pp.date_of_creation, pp.blockweekly
        FROM part_workers pp
        WHERE pp.cost_center_id = " + cost_center.to_s + " 
        ORDER BY pp.number_part DESC 
        LIMIT " + display_length
      )
  	end

  	part_workers.each do |part_worker|
  	  result << [
        part_worker[1], 
        part_worker[2], 
        case part_worker[3].to_i
        when 1
          "<a class='btn btn-success btn-xs' onclick=javascript:load_url_ajax('/administration/part_workers/" + part_worker[0].to_s + "','content',null,null,'GET')> Ver Información </a> "
        else
          "<a class='btn btn-success btn-xs' onclick=javascript:load_url_ajax('/administration/part_workers/" + part_worker[0].to_s + "','content',null,null,'GET')> Ver Información </a> " + "<a class='btn btn-warning btn-xs' onclick=javascript:load_url_ajax('/administration/part_workers/" + part_worker[0].to_s + "/edit','content',null,null,'GET')> Editar </a> " + "<a class='btn btn-danger btn-xs' data-onclick=javascript:delete_to_url('/administration/part_workers/" + part_worker[0].to_s + "','content','/administration/part_workers/') data-placement='left' data-popout='true' data-singleton='true' data-title='Esta seguro de eliminar la parte N°" + part_worker[0].to_s + "?' data-toggle='confirmation' data-original-title='' title=''> Eliminar </a>"
        end
      ]
  	end

  	return result
  end

end
