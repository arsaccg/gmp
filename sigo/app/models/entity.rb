class Entity < ActiveRecord::Base

  has_many :purchase_orders
  has_many :order_of_services
  has_many :subcontracts
  has_many :subcontract_equipments
  has_many :provisions
  has_many :entity_banks
  has_and_belongs_to_many :type_entities
  has_many :workers
  belongs_to :cost_center
  accepts_nested_attributes_for :type_entities, :allow_destroy => true
  accepts_nested_attributes_for :entity_banks, :allow_destroy => true

  include ActiveModel::Validations
  validates :ruc, :uniqueness => { :message => "El RUC debe ser unico."}, :allow_blank => true, :case_sensitive => false
  validates :dni, :uniqueness => { :message => "El DNI debe ser unico."}, :allow_blank => true, :case_sensitive => false

  def self.find_name_executor(executor_id)
    return Entity.find(executor_id).name
  end

  def self.find_name_supplier(supplier_id)
    return Entity.find(executor_id).name
  end

    def self.get_entities(type_ent, comp, display_length, pager_number, keyword)
    result = Array.new
    @type  = TypeEntity.find(type_ent.to_s)
    if keyword != '' && pager_number != 'NaN'
      if @type.preffix == "CL" || @type.preffix == "C"
        entities = ActiveRecord::Base.connection.execute("
          SELECT ent.id, ent.name, ent.ruc
          FROM entities ent, entities_type_entities ete
          WHERE ete.type_entity_id = "+type_ent.to_s+"
          AND ete.entity_id = ent.id
          AND (ent.name LIKE '%" + keyword + "%' OR ent.ruc LIKE '%" + keyword + "%')
          ORDER BY ent.id DESC 
          LIMIT " + display_length + " 
          OFFSET " + pager_number
        )
      elsif @type.preffix == "P"
        entities = ActiveRecord::Base.connection.execute("
          SELECT ent.id, ent.name, ent.address, ent.ruc
          FROM entities ent, entities_type_entities ete
          WHERE ete.type_entity_id = "+type_ent.to_s+"
          AND ete.entity_id = ent.id
          AND (ent.name LIKE '%" + keyword + "%' OR ent.ruc LIKE '%" + keyword + "%')
          ORDER BY ent.id DESC 
          LIMIT " + display_length + " 
          OFFSET " + pager_number
        )
      elsif @type.preffix == "T"
        entities = ActiveRecord::Base.connection.execute("
          SELECT ent.id, ent.name, CONCAT(ent.paternal_surname, ' ' ,ent.maternal_surname), ent.dni
          FROM entities ent, entities_type_entities ete
          WHERE ete.type_entity_id = "+type_ent.to_s+"
          AND ete.entity_id = ent.id
          AND (ent.name LIKE '%" + keyword + "%' OR ent.paternal_surname LIKE '%" + keyword + "%' OR ent.maternal_surname LIKE '%" + keyword + "%' OR ent.dni LIKE '%" + keyword + "%')
          ORDER BY ent.id DESC 
          LIMIT " + display_length + " 
          OFFSET " + pager_number
        )
        
      end
    elsif pager_number != 'NaN'
      if @type.preffix == "CL" || @type.preffix == "C"
        entities = ActiveRecord::Base.connection.execute("
          SELECT ent.id, ent.name, ent.ruc
          FROM entities ent, entities_type_entities ete
          WHERE ete.type_entity_id = "+type_ent.to_s+"
          AND ete.entity_id = ent.id
          ORDER BY ent.id DESC 
          LIMIT " + display_length + " 
          OFFSET " + pager_number
        )
      elsif @type.preffix == "P"
        entities = ActiveRecord::Base.connection.execute("
          SELECT ent.id, ent.name, ent.address, ent.ruc
          FROM entities ent, entities_type_entities ete
          WHERE ete.type_entity_id = "+type_ent.to_s+"
          AND ete.entity_id = ent.id
          ORDER BY ent.id DESC 
          LIMIT " + display_length + " 
          OFFSET " + pager_number
        )
      elsif @type.preffix == "T"
        entities = ActiveRecord::Base.connection.execute("
          SELECT ent.id, ent.name, CONCAT(ent.paternal_surname, ' ' ,ent.maternal_surname), ent.dni
          FROM entities ent, entities_type_entities ete
          WHERE ete.type_entity_id = "+type_ent.to_s+"
          AND ete.entity_id = ent.id
          ORDER BY ent.id DESC 
          LIMIT " + display_length + " 
          OFFSET " + pager_number
        )
        
      end
    else
      if @type.preffix == "CL" || @type.preffix == "C"
        entities = ActiveRecord::Base.connection.execute("
          SELECT ent.id, ent.name, ent.ruc
          FROM entities ent, entities_type_entities ete
          WHERE ete.type_entity_id = "+type_ent.to_s+"
          AND ete.entity_id = ent.id
          ORDER BY ent.id DESC 
          LIMIT " + display_length
        )
      elsif @type.preffix == "P"
        entities = ActiveRecord::Base.connection.execute("
          SELECT ent.id, ent.name, ent.address, ent.ruc
          FROM entities ent, entities_type_entities ete
          WHERE ete.type_entity_id = "+type_ent.to_s+"
          AND ete.entity_id = ent.id
          ORDER BY ent.id DESC 
          LIMIT " + display_length
        )
      elsif @type.preffix == "T"
        entities = ActiveRecord::Base.connection.execute("
          SELECT ent.id, ent.name, CONCAT(ent.paternal_surname, ' ' ,ent.maternal_surname), ent.dni
          FROM entities ent, entities_type_entities ete
          WHERE ete.type_entity_id = "+type_ent.to_s+"
          AND ete.entity_id = ent.id
          ORDER BY ent.id DESC 
          LIMIT " + display_length
        )
        
      end
    end

    entities.each do |ent|
      if @type.preffix == "CL" || @type.preffix == "C"
        result << [
          ent[1],
          ent[2],
          if @type.preffix == "CL"
            "<a class='btn btn-success btn-xs' onclick=javascript:load_url_ajax('/logistics/entities/"+ent[0].to_s+"','content',null,null,'GET')>Ver Detalle</a> "+"<a class='btn btn-info btn-xs' onclick=javascript:load_url_ajax('/logistics/entities/accounts','content',{entity:"+ent[0].to_s+"},null,'POST')>Cuentas Bancarias</a> "+"<a class='btn btn-danger btn-xs' data-onclick=javascript:delete_to_url('/logistics/entities/"+ent[0].to_s+"','content','/logistics/entities?company_id="+comp.to_s+"') data-placement='left' data-popout='true' data-singleton='true' data-title='Esta seguro de eliminar "+ent[1].to_s+"?' data-toggle='confirmation' data-original-title='' title=''>Eliminar</a>"
          else
            "<a class='btn btn-success btn-xs' onclick=javascript:load_url_ajax('/logistics/entities/"+ent[0].to_s+"','content',null,null,'GET')>Ver Detalle</a> "+"<a class='btn btn-info btn-xs' onclick=javascript:load_url_ajax('/logistics/entities/accounts','content',{entity:"+ent[0].to_s+"},null,'POST')>Cuentas Bancarias</a> "+"<a class='btn btn-warning btn-xs' onclick=javascript:load_url_ajax('/logistics/entities/"+ent[0].to_s+"/edit','content',{company_id:'"+comp.to_s+"',type:'entity'},null,'GET')> Editar </a> " + "<a class='btn btn-danger btn-xs' data-onclick=javascript:delete_to_url('/logistics/entities/"+ent[0].to_s+"','content','/logistics/entities?company_id="+comp.to_s+"') data-placement='left' data-popout='true' data-singleton='true' data-title='Esta seguro de eliminar "+ent[1].to_s+"?' data-toggle='confirmation' data-original-title='' title=''>Eliminar</a>"
          end
          

        ]

      elsif @type.preffix == "P"
        result << [
          ent[1],
          ent[2],
          ent[3],
          "<a class='btn btn-success btn-xs' onclick=javascript:load_url_ajax('/logistics/entities/"+ent[0].to_s+"','content',null,null,'GET')>Ver Detalle</a> "+"<a class='btn btn-info btn-xs' onclick=javascript:load_url_ajax('/logistics/entities/accounts','content',{entity:"+ent[0].to_s+"},null,'POST')>Cuentas Bancarias</a> "+"<a class='btn btn-warning btn-xs' onclick=javascript:load_url_ajax('/logistics/entities/"+ent[0].to_s+"/edit','content',{company_id:'"+comp.to_s+"',type:'entity'},null,'GET')> Editar </a> " + "<a class='btn btn-danger btn-xs' data-onclick=javascript:delete_to_url('/logistics/entities/"+ent[0].to_s+"','content','/logistics/entities?company_id="+comp.to_s+"') data-placement='left' data-popout='true' data-singleton='true' data-title='Esta seguro de eliminar "+ent[1].to_s+"?' data-toggle='confirmation' data-original-title='' title=''>Eliminar</a>"
        ]
      elsif @type.preffix == "T"
        result << [
          ent[1],
          ent[2],
          ent[3],
          "<a class='btn btn-success btn-xs' onclick=javascript:load_url_ajax('/logistics/entities/"+ent[0].to_s+"','content',null,null,'GET')>Ver Detalle</a> "+"<a class='btn btn-info btn-xs' onclick=javascript:load_url_ajax('/logistics/entities/accounts','content',{entity:"+ent[0].to_s+"},null,'POST')>Cuentas Bancarias</a> "+"<a class='btn btn-warning btn-xs' onclick=javascript:load_url_ajax('/logistics/entities/"+ent[0].to_s+"/edit','content',{company_id:'"+comp.to_s+"',type:'worker'},null,'GET')> Editar </a> " + "<a class='btn btn-danger btn-xs' data-onclick=javascript:delete_to_url('/logistics/entities/"+ent[0].to_s+"','content','/logistics/entities?company_id="+comp.to_s+"') data-placement='left' data-popout='true' data-singleton='true' data-title='Esta seguro de eliminar "+ent[1].to_s+"?' data-toggle='confirmation' data-original-title='' title=''>Eliminar</a>"
        ]
        
      end
    end
    return result
  end
end
