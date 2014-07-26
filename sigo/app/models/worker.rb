class Worker < ActiveRecord::Base
  has_many :part_person_details
  has_many :worker_details
  has_many :worker_familiars
  has_many :worker_center_of_studies
  has_many :worker_otherstudies
  has_many :worker_experiences
  has_many :part_of_equipments
  has_many :worker_contracts
  has_many :worker_afps
  has_many :worker_healths
  belongs_to :entity
  belongs_to :cost_center
  belongs_to :position_worker
  has_and_belongs_to_many :type_workdays

  state_machine :state, :initial => :working do

    event :register do
      transition :working => :registered
    end
    event :approve do
      transition :registered => :active
    end
    event :cancel do
      transition :active => :ceased
    end

  end

  accepts_nested_attributes_for :worker_details, :allow_destroy => true
  accepts_nested_attributes_for :worker_afps, :allow_destroy => true
  accepts_nested_attributes_for :worker_healths, :allow_destroy => true
  accepts_nested_attributes_for :worker_familiars, :allow_destroy => true
  accepts_nested_attributes_for :worker_center_of_studies, :allow_destroy => true
  accepts_nested_attributes_for :worker_otherstudies, :allow_destroy => true
  accepts_nested_attributes_for :worker_experiences, :allow_destroy => true

  has_attached_file :cv, :default_url => lambda { |image| ActionController::Base.helpers.asset_path('NotAvailable300.png') }
  validates_attachment_content_type :cv, :content_type => [ 'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',/\Aimage\/.*\Z/]

  has_attached_file :antecedent_police, :default_url => lambda { |image| ActionController::Base.helpers.asset_path('NotAvailable300.png') }
  validates_attachment_content_type :antecedent_police, :content_type => [ 'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',/\Aimage\/.*\Z/]

  has_attached_file :dni, :default_url => lambda { |image| ActionController::Base.helpers.asset_path('NotAvailable300.png') }
  validates_attachment_content_type :dni, :content_type => [ 'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',/\Aimage\/.*\Z/]

  has_attached_file :cts_deposit_letter, :default_url => lambda { |image| ActionController::Base.helpers.asset_path('NotAvailable300.png') }
  validates_attachment_content_type :cts_deposit_letter, :content_type => [ 'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',/\Aimage\/.*\Z/]

  has_attached_file :pension_funds_letter, :default_url => lambda { |image| ActionController::Base.helpers.asset_path('NotAvailable300.png') }
  validates_attachment_content_type :pension_funds_letter, :content_type => [ 'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',/\Aimage\/.*\Z/]

  has_attached_file :affidavit, :default_url => lambda { |image| ActionController::Base.helpers.asset_path('NotAvailable300.png') }
  validates_attachment_content_type :affidavit, :content_type => [ 'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',/\Aimage\/.*\Z/]

  has_attached_file :marriage_certificate, :default_url => lambda { |image| ActionController::Base.helpers.asset_path('NotAvailable300.png') }
  validates_attachment_content_type :marriage_certificate, :content_type => [ 'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',/\Aimage\/.*\Z/]

  has_attached_file :birth_certificate_of_childer, :default_url => lambda { |image| ActionController::Base.helpers.asset_path('NotAvailable300.png') }
  validates_attachment_content_type :birth_certificate_of_childer, :content_type => [ 'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',/\Aimage\/.*\Z/]

  has_attached_file :dni_wife_kids, :default_url => lambda { |image| ActionController::Base.helpers.asset_path('NotAvailable300.png') }
  validates_attachment_content_type :dni_wife_kids, :content_type => [ 'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',/\Aimage\/.*\Z/]

  has_attached_file :schoolar_certificate, :default_url => lambda { |image| ActionController::Base.helpers.asset_path('NotAvailable300.png') }
  validates_attachment_content_type :schoolar_certificate, :content_type => [ 'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',/\Aimage\/.*\Z/]

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
        SELECT wo.id, ent.name, ent.paternal_surname, ent.maternal_surname, pow.name, wo.email, ent.date_of_birth, ent.address, wo.state
        FROM workers wo, entities ent, position_workers pow 
        WHERE wo.entity_id = ent.id
        AND wo.position_worker_id = pow.id
        AND wo.cost_center_id = " + cost_center_id.to_s + " 
        AND (wo.id LIKE '%" + keyword + "%' OR ent.name LIKE '%" + keyword + "%' OR ent.paternal_surname LIKE '%" + keyword + "%' OR ent.maternal_surname LIKE '%" + keyword + "%' OR pow.name LIKE '%" + keyword + "%' OR wo.email LIKE '%" + keyword + "%' OR ent.date_of_birth LIKE '%" + keyword + "%' OR ent.address LIKE '%" + keyword + "%' OR wo.state LIKE '%" + keyword + "%') 
        ORDER BY wo.id ASC 
        LIMIT " + display_length + " 
        OFFSET " + pager_number
      )
    elsif pager_number != 'NaN'
      part_people = ActiveRecord::Base.connection.execute("
        SELECT wo.id, ent.name, ent.paternal_surname, ent.maternal_surname, pow.name, wo.email, ent.date_of_birth, ent.address, wo.state
        FROM workers wo, entities ent, position_workers pow 
        WHERE wo.entity_id = ent.id
        AND wo.position_worker_id = pow.id
        AND wo.cost_center_id = " + cost_center_id.to_s + " 
        ORDER BY wo.id ASC 
        LIMIT " + display_length + " 
        OFFSET " + pager_number
      )
    else
      part_people = ActiveRecord::Base.connection.execute("
        SELECT wo.id, ent.name, ent.paternal_surname, ent.maternal_surname, pow.name, wo.email, ent.date_of_birth, ent.address, wo.state
        FROM workers wo, entities ent, position_workers pow 
        WHERE wo.entity_id = ent.id
        AND wo.position_worker_id = pow.id
        AND wo.cost_center_id = " + cost_center_id.to_s + " 
        ORDER BY wo.id ASC 
        LIMIT " + display_length
      )
    end

    part_people.each do |part_person|
      if part_person[8]=="working"
        result << [
          part_person[0], 
          part_person[1], 
          part_person[2], 
          part_person[3],
          part_person[4],
          part_person[5],
          part_person[6],
          part_person[7],
          "Trabajando",
          "<a class='btn btn-info btn-xs' onclick=javascript:load_url_ajax('/production/worker_contracts','content',{worker_id:'" + part_person[0].to_s + "'},null,'GET')>Contratos</a>" + "<a class='btn btn-info btn-xs' onclick=javascript:load_url_ajax('/production/worker_contracts','content',{worker_id:'" + part_person[0].to_s + "'},null,'GET')>Contratos</a>" + "<a class='btn btn-warning btn-xs' onclick=javascript:load_url_ajax('/production/workers/" + part_person[0].to_s + "/edit','content',null,null,'GET')> Editar </a> " + "<a class='btn btn-danger btn-xs' data-onclick=javascript:delete_to_url('/production/workers/" + part_person[0].to_s + "','content','/production/workers/') data-placement='left' data-popout='true' data-singleton='true' data-title='Esta seguro de eliminar el trabajador N°" + part_person[0].to_s + "?' data-toggle='confirmation' data-original-title='' title=''> Eliminar </a>"
        ]
      elsif part_person[8]=="registered"
        result << [
          part_person[0], 
          part_person[1], 
          part_person[2], 
          part_person[3],
          part_person[4],
          part_person[5],
          part_person[6],
          part_person[7],
          "Registrado",
          "<a class='btn btn-info btn-xs' onclick=javascript:load_url_ajax('/production/worker_contracts','content',{worker_id:'" + part_person[0].to_s + "'},null,'GET')>Contratos</a>" + "<a class='btn btn-warning btn-xs' onclick=javascript:load_url_ajax('/production/workers/" + part_person[0].to_s + "/edit','content',null,null,'GET')> Editar </a> " + "<a class='btn btn-danger btn-xs' data-onclick=javascript:delete_to_url('/production/workers/" + part_person[0].to_s + "','content','/production/workers/') data-placement='left' data-popout='true' data-singleton='true' data-title='Esta seguro de eliminar el trabajador N°" + part_person[0].to_s + "?' data-toggle='confirmation' data-original-title='' title=''> Eliminar </a>"
        ]
      elsif part_person[8]=="active"
        result << [
          part_person[0], 
          part_person[1], 
          part_person[2], 
          part_person[3],
          part_person[4],
          part_person[5],
          part_person[6],
          part_person[7],
          "Activo",
          "<a class='btn btn-info btn-xs' onclick=javascript:load_url_ajax('/production/worker_contracts','content',{worker_id:'" + part_person[0].to_s + "'},null,'GET')>Contratos</a>" + "<a class='btn btn-warning btn-xs' onclick=javascript:load_url_ajax('/production/workers/" + part_person[0].to_s + "/edit','content',null,null,'GET')> Editar </a> " + "<a class='btn btn-danger btn-xs' data-onclick=javascript:delete_to_url('/production/workers/" + part_person[0].to_s + "','content','/production/workers/') data-placement='left' data-popout='true' data-singleton='true' data-title='Esta seguro de eliminar el trabajador N°" + part_person[0].to_s + "?' data-toggle='confirmation' data-original-title='' title=''> Eliminar </a>"
        ]
      elsif part_person[8]=="ceased"
        result << [
          part_person[0], 
          part_person[1], 
          part_person[2], 
          part_person[3],
          part_person[4],
          part_person[5],
          part_person[6],
          part_person[7],
          "Cesado",
          "<a class='btn btn-info btn-xs' onclick=javascript:load_url_ajax('/production/worker_contracts','content',{worker_id:'" + part_person[0].to_s + "'},null,'GET')>Contratos</a>" + "<a class='btn btn-warning btn-xs' onclick=javascript:load_url_ajax('/production/workers/" + part_person[0].to_s + "/edit','content',null,null,'GET')> Editar </a> " + "<a class='btn btn-danger btn-xs' data-onclick=javascript:delete_to_url('/production/workers/" + part_person[0].to_s + "','content','/production/workers/') data-placement='left' data-popout='true' data-singleton='true' data-title='Esta seguro de eliminar el trabajador N°" + part_person[0].to_s + "?' data-toggle='confirmation' data-original-title='' title=''> Eliminar </a>"
        ]
      else
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
          "<a class='btn btn-info btn-xs' onclick=javascript:load_url_ajax('/production/worker_contracts','content',{worker_id:'" + part_person[0].to_s + "'},null,'GET')>Contratos</a>" + "<a class='btn btn-warning btn-xs' onclick=javascript:load_url_ajax('/production/workers/" + part_person[0].to_s + "/edit','content',null,null,'GET')> Editar </a> " + "<a class='btn btn-danger btn-xs' data-onclick=javascript:delete_to_url('/production/workers/" + part_person[0].to_s + "','content','/production/workers/') data-placement='left' data-popout='true' data-singleton='true' data-title='Esta seguro de eliminar el trabajador N°" + part_person[0].to_s + "?' data-toggle='confirmation' data-original-title='' title=''> Eliminar </a>"
        ]
      end
    end

    return result
  end

end
