module ApplicationHelper
  def translate_delivery_order_state(str_value)
    str_spanish = ""
    case str_value
      when "pre_issued"
        str_spanish="PRE-EMITIDO"
      when "issued"
        str_spanish="EMITIDO"
      when "revised"
      	str_spanish="VISTO BUENO"
      when "canceled"
      	str_spanish="CANCELADO"
      when "approved"
        str_spanish="APROBADO"
    end
  end

  def translate_user_role(str_role)
    str_spanish = ""
    case str_role
      when "director"
        str_spanish="DIRECTOR"
      when "approver"
        str_spanish="APROBAR ORDENES DE SUMINISTRO"
      when "reviser"
        str_spanish="DAR VISTO BUENO A LAS ORDENES DE SUMINISTRO"
      when "canceller"
        str_spanish="CANCELAR ORDENES DE SUMINISTRO"
    end
  end

  def translate_purchase_order_state(str_value)
    str_spanish = ""
    case str_value
      when "pre_issued"
        str_spanish="PRE-EMITIDO"
      when "issued"
        str_spanish="EMITIDO"
      when "revised"
        str_spanish="VISTO BUENO"
      when "canceled"
        str_spanish="CANCELADO"
      when "approved"
        str_spanish="APROBADO"
    end
  end

  def translate_order_service_state(str_value)
    str_spanish = ""
    case str_value
      when "pre_issued"
        str_spanish="PRE-EMITIDO"
      when "issued"
        str_spanish="EMITIDO"
      when "revised"
        str_spanish="VISTO BUENO"
      when "canceled"
        str_spanish="CANCELADO"
      when "approved"
        str_spanish="APROBADO"
    end
  end

  def get_next_state(str_state)
    str_spanish = ""
    case str_state
      when "pre_issued"
        str_spanish="issued"
      when "issued"
        str_spanish="revised"
      when "revised"
        str_spanish="approved"
    end
  end

  def get_prev_state(str_state)
    str_spanish = ""
    case str_state
      when "approved"
        str_spanish="revised"
      when "revised"
        str_spanish="issued"
      when "issued"
        str_spanish="observed"
    end
  end

  def get_company_cost_center
    data = Array.new
    data << Rails.cache.read('company')
    data << Rails.cache.read('cost_center')
    return data
  end
end
