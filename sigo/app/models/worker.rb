class Worker < ActiveRecord::Base
	has_many :part_person_details
	has_many :worker_details
	has_many :part_of_equipments
	belongs_to :entity
	belongs_to :cost_center
	belongs_to :position_worker
	belongs_to :article

	accepts_nested_attributes_for :worker_details, :allow_destroy => true

	def self.find_name_front_chief(front_chief_id)
	  return Worker.find(front_chief_id).first_name + ' ' + Worker.find(front_chief_id).second_name + ' ' + Worker.find(front_chief_id).paternal_surname + ' ' + Worker.find(front_chief_id).maternal_surname
	end

	def self.find_name_master_builder(master_builder_id)
	  return Worker.find(master_builder_id).first_name + ' ' + Worker.find(master_builder_id).second_name + ' ' + Worker.find(master_builder_id).paternal_surname + ' ' + Worker.find(master_builder_id).maternal_surname
	end

	def self.get_workers(cost_center_id, display_length, pager_number, keyword = '')
  	result = Array.new
  	if keyword != '' && pager_number != 'NaN'
      part_people = ActiveRecord::Base.connection.execute("
        SELECT wo.id, ent.name, ent.paternal_surname, ent.maternal_surname, pow.name, art.name, wo.email, ent.date_of_birth, ent.address
        FROM workers wo, entities ent, articles art, position_workers pow 
        WHERE wo.entity_id = ent.id
        AND wo.article_id = art.id
        AND wo.position_worker_id = pow.id
        AND wo.cost_center_id = " + cost_center_id.to_s + " 
        AND (wo.id LIKE '%" + keyword + "%' OR ent.name LIKE '%" + keyword + "%' OR ent.paternal_surname LIKE '%" + keyword + "%' OR ent.maternal_surname LIKE '%" + keyword + "%' OR pow.name LIKE '%" + keyword + "%' OR art.name LIKE '%" + keyword + "%' OR wo.email LIKE '%" + keyword + "%' OR ent.date_of_birth LIKE '%" + keyword + "%' OR ent.address LIKE '%" + keyword + "%') 
        ORDER BY wo.id ASC 
        LIMIT " + display_length + " 
        OFFSET " + pager_number
      )
  	elsif pager_number != 'NaN'
      part_people = ActiveRecord::Base.connection.execute("
        SELECT wo.id, ent.name, ent.paternal_surname, ent.maternal_surname, pow.name, art.name, wo.email, ent.date_of_birth, ent.address
        FROM workers wo, entities ent, articles art, position_workers pow 
        WHERE wo.entity_id = ent.id
        AND wo.article_id = art.id
        AND wo.position_worker_id = pow.id
        AND wo.cost_center_id = " + cost_center_id.to_s + " 
        ORDER BY wo.id ASC 
        LIMIT " + display_length + " 
        OFFSET " + pager_number
      )
  	else
  	  part_people = ActiveRecord::Base.connection.execute("
        SELECT wo.id, ent.name, ent.paternal_surname, ent.maternal_surname, pow.name, art.name, wo.email, ent.date_of_birth, ent.address
        FROM workers wo, entities ent, articles art, position_workers pow 
        WHERE wo.entity_id = ent.id
        AND wo.article_id = art.id
        AND wo.position_worker_id = pow.id
        AND wo.cost_center_id = " + cost_center_id.to_s + " 
        ORDER BY wo.id ASC 
        LIMIT " + display_length
      )
  	end

  	part_people.each do |part_person|
  	  result << [
  	  	part_person[0], 
        part_person[1], 
        part_person[2], 
        part_person[3],
        part_person[4],
        part_person[5],
        part_person[6],
        part_person[7],
        part_person[8],
        "<a class='btn btn-warning btn-xs' onclick=javascript:load_url_ajax('/production/workers/" + part_person[0].to_s + "/edit','content',null,null,'GET')> Editar </a> " + "<a class='btn btn-danger btn-xs' data-onclick=javascript:delete_to_url('/production/workers/" + part_person[0].to_s + "','content','/production/workers/') data-placement='left' data-popout='true' data-singleton='true' data-title='Esta seguro de eliminar el trabajador N°" + part_person[0].to_s + "?' data-toggle='confirmation' data-original-title='' title=''> Eliminar </a>"
      ]
  	end

  	return result
  end

end
