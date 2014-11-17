class Formule < ActiveRecord::Base

  def self.translate_formules(const_variables)
    str_sentence = sentence
    const_variables.each do |c|
      case c
        when "[total_compras_al_anho_actual_red]"
          user = params[:user]
          total_purchase = 0
          user.children.each do |child|
            child.purchases.where('updated_at > ?', Time.now.beginning_of_year).each do |purchase|
              purchase.purchase_items.each do |pi|
                total_purchase += pi.amount.to_f*pi.product.price.to_f
              end
            end
          end
          str_sentence.gsub! c, total_purchase.to_s
        when "[total_compras_al_anho]"
          user = params[:user]
          total_own_purchase = 0
          user.purchases.where('updated_at > ?', Time.now.beginning_of_year).each do |purchase|
            purchase.purchase_items.each do |pi|
              total_own_purchase += pi.amount.to_f*pi.product.price.to_f
            end
          end
          str_sentence.gsub! c, total_own_purchase.to_s
        when "[total_ventas_distribuidores]"
          user = params[:user]
          total_purchase_distro = 0
          user.children.each do |child|
            if child.level_id == 2
            child.purchases.where('updated_at > ?', Time.now.beginning_of_year).each do |purchase|
              purchase.purchase_items.each do |pi|
                total_purchase_distro += pi.amount.to_f*pi.product.price.to_f
              end
            end
          end
          end
          total_purchase_distro = 0.05*total_purchase_distro
          str_sentence.gsub! c, total_purchase_distro.to_s
        when "[categoria_por_cantidad]"
          items = params[:purchase_items]
          total_quantity = 0
          if items != nil
            items.each do |item|
              total_quantity = total_quantity + (item.amount.to_f)*(item.product.category.coefficient.to_f)
            end
        end
          str_sentence.gsub! c, total_quantity.to_s
        when "[categoria_por_monto]"
          items = params[:purchase_items]
          total_amount = 0
          if items != nil
          items.each do |item|

            total_amount = total_amount + ((item.amount.to_f*item.product.price.to_f)*(item.product.category.coefficient.to_f))
          end
          end
          str_sentence.gsub! c, total_amount.to_s
      when "[total_compras_monto]"
        total_amount_buy = (params[:total_amount_buy].to_f/5).to_f
        str_sentence.gsub! c, total_amount_buy.to_s
      when "[total_compras_cantidad]"
        str_sentence.gsub! c, params[:total_quantity_buy].to_s
      when "[puntos_usuarios]"
        str_sentence.gsub! c, params[:user_points].to_s
        puts params[:user_points]
      end
    end
    puts str_sentence
    return eval(str_sentence.to_s)
  end

end
