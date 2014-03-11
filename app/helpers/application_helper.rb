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
end
