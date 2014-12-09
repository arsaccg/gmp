class Payroll < ActiveRecord::Base
  has_many :payroll_details
  belongs_to :worker
  accepts_nested_attributes_for :payroll_details, :allow_destroy => true

	def self.getWorker(word, name)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT e.id, e.name, e.second_name, e.paternal_surname, e.maternal_surname
      FROM workers w, entities e
      WHERE ( e.name LIKE '%#{word}%' OR e.second_name LIKE '%#{word}%' OR e.paternal_surname LIKE '%#{word}%' OR e.maternal_surname LIKE '%#{word}%' )
      AND e.maternal_surname IS NOT NULL 
      AND e.id = w.entity_id 
    ")
    return mysql_result
  end

  def self.show_w(cost_center_id, display_length, pager_number, keyword = '')
    result = Array.new
    if keyword != '' && pager_number != 'NaN'
      part_people = ActiveRecord::Base.connection.execute("
        SELECT wo.id, ent.name, ent.paternal_surname, ent.maternal_surname
        FROM workers wo, entities ent, articles art, worker_contracts wc
        WHERE wo.entity_id = ent.id
        AND wc.worker_id = wo.id
        AND wc.article_id = art.id
        AND wo.cost_center_id = " + cost_center_id.to_s + " 
        AND (wo.id LIKE '%" + keyword + "%' OR ent.name LIKE '%" + keyword + "%' OR ent.paternal_surname LIKE '%" + keyword + "%' OR ent.maternal_surname LIKE '%" + keyword + "%' OR pow.name LIKE '%" + keyword + "%' OR art.name LIKE '%" + keyword + "%' OR wo.email LIKE '%" + keyword + "%' OR ent.date_of_birth LIKE '%" + keyword + "%' OR ent.address LIKE '%" + keyword + "%') 
        Group by wo.id
        ORDER BY wo.id ASC 
        LIMIT " + display_length + " 
        OFFSET " + pager_number
      )
    elsif pager_number != 'NaN'
      part_people = ActiveRecord::Base.connection.execute("
        SELECT wo.id, ent.name, ent.paternal_surname, ent.maternal_surname
        FROM workers wo, entities ent, articles art, worker_contracts wc
        WHERE wo.entity_id = ent.id
        AND wc.worker_id = wo.id
        AND wc.article_id = art.id
        AND wo.cost_center_id = " + cost_center_id.to_s + " 
        Group by wo.id
        ORDER BY wo.id ASC 
        LIMIT " + display_length + " 
        OFFSET " + pager_number
      )
    else
      part_people = ActiveRecord::Base.connection.execute("
        SELECT wo.id, ent.name, ent.paternal_surname, ent.maternal_surname
        FROM workers wo, entities ent, articles art, worker_contracts wc
        WHERE wo.entity_id = ent.id
        AND wc.worker_id = wo.id
        AND wc.article_id = art.id
        AND wo.cost_center_id = " + cost_center_id.to_s + " 
        Group by wo.id
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
        "<a class='btn btn-success btn-xs' onclick=javascript:load_url_ajax('/payrolls/payrolls/"+part_person[0].to_s+"','content',null,null,'GET')>Ver Datos de Pago</a>" + "<a class='btn btn-info btn-xs' onclick=javascript:load_url_ajax('/payrolls/payrolls/new','content',{worker_id:'" + part_person[0].to_s + "'},null,'GET')>Datos de Pago</a>"+ "<a class='btn btn-warning btn-xs' onclick=javascript:load_url_ajax('/payrolls/payrolls/" + part_person[0].to_s + "/edit','content',null,null,'GET')>Editar Datos de Pago</a>"
      ]
    end
    return result
  end
end