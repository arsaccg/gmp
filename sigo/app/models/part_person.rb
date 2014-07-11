class PartPerson < ActiveRecord::Base
  has_many :part_person_details
  belongs_to :cost_center
  belongs_to :working_group
  accepts_nested_attributes_for :part_person_details, :allow_destroy => true

  def self.get_part_people(cost_center_id, display_length, pager_number, keyword = '')
  	result = Array.new
  	if keyword != '' && pager_number != 'NaN'
      part_people = ActiveRecord::Base.connection.execute("
        SELECT pp.id, pp.number_part, wg.name, pp.date_of_creation
        FROM part_people pp, working_groups wg
        WHERE pp.working_group_id = wg.id
        AND pp.cost_center_id = " + cost_center_id.to_s + " 
        AND (pp.number_part LIKE '%" + keyword + "%' OR wg.name LIKE '%" + keyword + "%' OR pp.date_of_creation LIKE '%" + keyword + "%') 
        ORDER BY pp.number_part DESC 
        LIMIT " + display_length + " 
        OFFSET " + pager_number
      )
  	elsif pager_number != 'NaN'
      part_people = ActiveRecord::Base.connection.execute("
        SELECT pp.id, pp.number_part, wg.name, pp.date_of_creation
        FROM part_people pp, working_groups wg
        WHERE pp.working_group_id = wg.id
        AND pp.cost_center_id = " + cost_center_id.to_s + " 
        ORDER BY pp.number_part DESC 
        LIMIT " + display_length + " 
        OFFSET " + pager_number
      )
  	else
  	  part_people = ActiveRecord::Base.connection.execute("
        SELECT pp.id, pp.number_part, wg.name, pp.date_of_creation
        FROM part_people pp, working_groups wg
        WHERE pp.working_group_id = wg.id
        AND pp.cost_center_id = " + cost_center_id.to_s + " 
        ORDER BY pp.number_part DESC 
        LIMIT " + display_length
      )
  	end

  	part_people.each do |part_person|
  	  result << [
        part_person[1], 
        part_person[2], 
        part_person[3],
        "<a class='btn btn-success btn-xs' onclick=javascript:load_url_ajax('/production/part_people/" + part_person[0].to_s + "','content',null,null,'GET')> Ver Información </a> " + "<a class='btn btn-warning btn-xs' onclick=javascript:load_url_ajax('/production/part_people/" + part_person[0].to_s + "/edit','content',null,null,'GET')> Editar </a> " + "<a class='btn btn-danger btn-xs' data-onclick=javascript:delete_to_url('/production/part_people/" + part_person[0].to_s + "','content','/production/part_people/') data-placement='left' data-popout='true' data-singleton='true' data-title='Esta seguro de eliminar la parte N°" + part_person[0].to_s + "?' data-toggle='confirmation' data-original-title='' title=''> Eliminar </a>"
      ]
  	end

  	return result
  end
end
