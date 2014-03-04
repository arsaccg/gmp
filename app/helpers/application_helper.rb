module ApplicationHelper
  def translate_delivery_order_state(str_value)
    str_spanish = ""
    case str_value
      when "issued"
        str_spanish="EMITIDO"
    end
  end
end
