class Logistics::PurchaseOrdersController < ApplicationController
  include ApplicationHelper
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete], if: Proc.new { |c| c.request.format.json? }
  def index
    @company = params[:company_id]
    @company = get_company_cost_center('company')
    cost_center = get_company_cost_center('cost_center')
    @purchaseOrders = PurchaseOrder.where('cost_center_id = ?', cost_center)
    @deliveryOrders = DeliveryOrder.where("cost_center_id = ? AND state LIKE ?", cost_center,'approved')
    render layout: false
  end

  def show
    @company = params[:company_id]
    @parcial_without_igv = 0
    @igv = 0
    @parcial_with_igv = 0
    @purchaseOrder = PurchaseOrder.find(params[:id])
    if params[:state_change] != nil
      @state_change = params[:state_change]
      if params[:type_of_order] != nil
        @type_of_order = params[:type_of_order]
      end
    else
      @purchasePerState = @purchaseOrder.state_per_order_purchases
    end
    @purchaseOrderDetails = @purchaseOrder.purchase_order_details
    
    render layout: false
  end

  def display_proveedor
    if params[:element].nil?
      word = params[:q]
    else
      word = params[:element]
    end
    article_hash = Array.new
    @name = get_company_cost_center('cost_center')
    type_ent = TypeEntity.find_by_preffix('P').id
    if !params[:element].nil?
      articles = ActiveRecord::Base.connection.execute("
            SELECT ent.id, ent.name, ent.ruc
            FROM entities ent, entities_type_entities ete
            WHERE ete.type_entity_id = "+type_ent.to_s+"
            AND ete.entity_id = ent.id
            AND ent.id = " + word.to_s
          )      
    else
      articles = ActiveRecord::Base.connection.execute("
            SELECT ent.id, ent.name, ent.ruc
            FROM entities ent, entities_type_entities ete
            WHERE ete.type_entity_id = "+type_ent.to_s+"
            AND ete.entity_id = ent.id
            AND (ent.id = '%"+word.to_s+"%' OR ent.name LIKE '%" + word.to_s + "%' OR ent.ruc LIKE '%" + word.to_s + "%')"
          )
    end
    articles.each do |art|
      article_hash << {'id' => art[0].to_s, 'code' => art[2], 'name' => art[1]}
    end
    render json: {:articles => article_hash}
  end

  def new
    @company = get_company_cost_center('company')
    @cost_center = get_company_cost_center('cost_center')
    @purchaseOrder = PurchaseOrder.new
    #Calcular IGV
    FinancialVariable.where("name LIKE '%IGV%'").each do |val|
      @igv= val.value.to_f+1
    end
    TypeEntity.where("id = 1").each do |tent|
      @suppliers = tent.entities
    end
    @last = PurchaseOrder.find(:last,:conditions => [ "cost_center_id = ?", @cost_center])
    if !@last.nil?
      @numbercode = @last.code.to_i+1
    else
      @numbercode = 1
    end
    @deliveryOrders = DeliveryOrder.where("cost_center_id = ? AND state LIKE ?", @cost_center,'approved')
    @moneys = Money.all
    @methodOfPayments = MethodOfPayment.all
    @numbercode = @numbercode.to_s.rjust(5,'0')
    #= hidden_field_tag 'purchase_order[code]', @numbercode
    render layout: false
  end

  def edit
    @company = params[:company_id]
    @reg_n = ((Time.now.to_f)*100).to_i
    @purchaseOrder = PurchaseOrder.find(params[:id])
    #Calcular IGV
    FinancialVariable.where("name LIKE '%IGV%'").each do |val|
      @igv= val.value.to_f+1
    end
    TypeEntity.where("id = 1").each do |tent|
      @suppliers = tent.entities
    end
    @cost_center = CostCenter.all
    @moneys = Money.all
    @methodOfPayments = MethodOfPayment.all
    @extra_calculations = ExtraCalculation.all
    @action = 'edit'
    render layout: false
  end

  def add_items_from_delivery_orders
    @reg_n = ((Time.now.to_f)*100).to_i
    @delivery_orders_detail = Array.new
    @for_id_modal = params[:ids_delivery_order]
    params[:ids_delivery_order].each do |ido|
      @delivery_order_detail = DeliveryOrderDetail.find(ido)
      total = @delivery_order_detail.amount
      sum = 0
      @delivery_order_detail.purchase_order_details.each do |pod|
        if pod.amount == nil
          sum += 0
        else
          sum += pod.amount
        end
      end
      @delivery_order_detail.amount = total - sum
      @delivery_orders_detail << @delivery_order_detail
    end
    render(partial: 'table_order_delivery_items', :layout => false)
  end

  def display_orders
    @cc = get_company_cost_center('cost_center')
    display_length = params[:iDisplayLength]
    pager_number = params[:iDisplayStart]
    @pagenumber = params[:iDisplayStart]
    keyword = params[:sSearch]
    state = params[:state]
    array = Array.new
    if @pagenumber != 'NaN' && keyword != ''
      if state == ""
        po = ActiveRecord::Base.connection.execute("
          SELECT po.id, po.state, po.description, CONCAT_WS( ' ', e.name, e.paternal_surname), po.expiration_date, CONCAT_WS( ' ', u.first_name, u.last_name),po.code
          FROM purchase_orders po, users u, entities e
          WHERE po.cost_center_id = "+@cc.to_s+"
          AND po.user_id = u.id
          AND po.entity_id = e.id
          AND (po.id LIKE '%"+keyword.to_s+"%' OR po.description LIKE '%"+keyword.to_s+"%' OR po.code LIKE '%"+keyword.to_s+"%' OR e.name LIKE '%"+keyword.to_s+"%' )
          ORDER BY po.id DESC
          LIMIT #{display_length}
          OFFSET #{pager_number}"
        )
      else
        po = ActiveRecord::Base.connection.execute("
          SELECT po.id, po.state, po.description, CONCAT_WS( ' ', e.name, e.paternal_surname), po.expiration_date, CONCAT_WS( ' ', u.first_name, u.last_name),po.code
          FROM purchase_orders po, users u, entities e
          WHERE po.cost_center_id = "+@cc.to_s+"
          AND po.user_id = u.id
          AND po.entity_id = e.id
          AND po.state LIKE '"+state.to_s+"'
          AND (po.id LIKE '%"+keyword.to_s+"%' OR po.description LIKE '%"+keyword.to_s+"%' OR po.code LIKE '%"+keyword.to_s+"%' OR e.name LIKE '%"+keyword.to_s+"%' )
          ORDER BY po.id DESC
          LIMIT #{display_length}
          OFFSET #{pager_number}"
        )        
      end
    elsif @pagenumber == 'NaN'
      if state == ""
        po = ActiveRecord::Base.connection.execute("
          SELECT po.id, po.state, po.description, CONCAT_WS( ' ', e.name, e.paternal_surname), po.expiration_date, CONCAT_WS( ' ', u.first_name, u.last_name),po.code
          FROM purchase_orders po, users u, entities e
          WHERE po.cost_center_id = "+@cc.to_s+"
          AND po.user_id = u.id
          AND po.entity_id = e.id
          ORDER BY po.id DESC
          LIMIT #{display_length}"
        )
      else
        po = ActiveRecord::Base.connection.execute("
          SELECT po.id, po.state, po.description, CONCAT_WS( ' ', e.name, e.paternal_surname), po.expiration_date, CONCAT_WS( ' ', u.first_name, u.last_name),po.code
          FROM purchase_orders po, users u, entities e
          WHERE po.cost_center_id = "+@cc.to_s+"
          AND po.user_id = u.id
          AND po.entity_id = e.id
          AND po.state LIKE '"+state.to_s+"'  
          ORDER BY po.id DESC
          LIMIT #{display_length}"
        )
      end
    elsif keyword != ''
      if state == ""
        po = ActiveRecord::Base.connection.execute("
          SELECT po.id, po.state, po.description, CONCAT_WS( ' ', e.name, e.paternal_surname), po.expiration_date, CONCAT_WS( ' ', u.first_name, u.last_name),po.code
          FROM purchase_orders po, users u, entities e
          WHERE po.cost_center_id = "+@cc.to_s+"
          AND po.user_id = u.id
          AND po.entity_id = e.id
          ORDER BY po.id DESC"
        )
      else
        po = ActiveRecord::Base.connection.execute("
          SELECT po.id, po.state, po.description, CONCAT_WS( ' ', e.name, e.paternal_surname), po.expiration_date, CONCAT_WS( ' ', u.first_name, u.last_name),po.code
          FROM purchase_orders po, users u, entities e
          WHERE po.cost_center_id = "+@cc.to_s+"
          AND po.user_id = u.id
          AND po.entity_id = e.id
          AND po.state LIKE '"+state.to_s+"' 
          ORDER BY po.id DESC"
        )        
      end       
    else
      if state == ""
        po = ActiveRecord::Base.connection.execute("
          SELECT po.id, po.state, po.description, CONCAT_WS( ' ', e.name, e.paternal_surname), po.expiration_date, CONCAT_WS( ' ', u.first_name, u.last_name),po.code
          FROM purchase_orders po, users u, entities e
          WHERE po.cost_center_id = "+@cc.to_s+"
          AND po.user_id = u.id
          AND po.entity_id = e.id
          ORDER BY po.id DESC
          LIMIT #{display_length}
          OFFSET #{pager_number}"
        )
      else
        po = ActiveRecord::Base.connection.execute("
          SELECT po.id, po.state, po.description, CONCAT_WS( ' ', e.name, e.paternal_surname), po.expiration_date, CONCAT_WS( ' ', u.first_name, u.last_name),po.code
          FROM purchase_orders po, users u, entities e
          WHERE po.cost_center_id = "+@cc.to_s+"
          AND po.user_id = u.id
          AND po.entity_id = e.id
          AND po.state LIKE '"+state.to_s+"'
          ORDER BY po.id DESC
          LIMIT #{display_length}
          OFFSET #{pager_number}"
        )
      end
    end

    po.each do |dos|
      @state = ""
      @action = ""
      @description = ""
      @last_state_date = ""
      case dos[1]
      when 'pre_issued'
        @state = "<i class='fa fa-flag' style='visibility: hidden;margin-right: 15px;'></i><span class='label' style='color: #000;'>"+translate_purchase_order_state(dos[1])+"</span>"
        if current_user.has_role? :canceller
          @action = "<a style='margin-right: 5px;' class='btn btn-warning btn-xs' data-original-title='Editar' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"/edit','content',{company_id:"+get_company_cost_center('company').to_s+"},null,'GET') rel='tooltip'><i class='fa fa-edit'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_next_state(dos[1].to_s)+"'},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-danger btn-xs' data-original-title='Eliminar Orden' data-placement='top' onclick=javascript:delete_to_url('/logistics/purchase_orders/"+dos[0].to_s+"','content','/logistics/purchase_orders?company_id="+get_company_cost_center('company').to_s+"') rel='tooltip'><i class='fa fa-trash-o'></i></a>"
        else
          "<a style='margin-right: 5px;' class='btn btn-warning btn-xs' data-original-title='Editar' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"/edit','content',{company_id:"+get_company_cost_center('company').to_s+"},null,'GET') rel='tooltip'><i class='fa fa-edit'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_next_state(dos[1].to_s)+"'},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>"
        end

      when 'issued'
        @state = "<i class='fa fa-flag' style='color: #FF7A00;margin-right: 15px;'></i><span class='label label-warning' style='background-color: #FF7A00;'>"+translate_purchase_order_state(dos[1])+"</span>"
        if current_user.has_role? :canceller
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',null,null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-success btn-xs' data-original-title='Retroceder el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_prev_state(dos[1])+"'},null,'GET') rel='tooltip'><i class='fa fa-mail-reply'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_next_state(dos[1])+"'},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/purchase_orders/"+dos[0].to_s+"/purchase_order_pdf.pdf?company_id="+get_company_cost_center('company').to_s+"' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-danger btn-xs' data-original-title='Anular' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'canceled'},null,'GET') rel='tooltip'><i class='fa fa-times'></i></a>"
        else
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',null,null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-success btn-xs' data-original-title='Retroceder el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_prev_state(dos[1])+"'},null,'GET') rel='tooltip'><i class='fa fa-mail-reply'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_next_state(dos[1])+"'},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/purchase_orders/"+dos[0].to_s+"/purchase_order_pdf.pdf?company_id="+get_company_cost_center('company').to_s+"' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>"
        end

      when 'revised'
        @state = "<i class='fa fa-flag' style='color: #c79121;margin-right: 15px;'></i><span class='label label-warning'>"+translate_purchase_order_state(dos[1])+"</span>"
        if current_user.has_role? :canceller
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',null,null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-success btn-xs' data-original-title='Retroceder el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_prev_state(dos[1])+"'},null,'GET') rel='tooltip'><i class='fa fa-mail-reply'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_next_state(dos[1])+"'},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/purchase_orders/"+dos[0].to_s+"/purchase_order_pdf.pdf?company_id="+get_company_cost_center('company').to_s+"' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-danger btn-xs' data-original-title='Anular' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'canceled'},null,'GET') rel='tooltip'><i class='fa fa-times'></i></a>"
        else
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',null,null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-success btn-xs' data-original-title='Retroceder el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_prev_state(dos[1])+"'},null,'GET') rel='tooltip'><i class='fa fa-mail-reply'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_next_state(dos[1])+"'},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/purchase_orders/"+dos[0].to_s+"/purchase_order_pdf.pdf?company_id="+get_company_cost_center('company').to_s+"' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>"
        end

      when 'canceled'
        @state = "<i class='fa fa-flag' style='color: #a90329;margin-right: 15px;'></i><span class='label label-danger'>"+translate_purchase_order_state(dos[1])+"</span>"
        @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',null,null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/purchase_orders/"+dos[0].to_s+"/purchase_order_pdf.pdf?company_id="+get_company_cost_center('company').to_s+"' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>"

      when 'approved'
        @state= "<i class='fa fa-flag' style='color: #25CA25;margin-right: 15px;'></i><span class='label label-success' style='background-color: #25CA25;'>"+translate_purchase_order_state(dos[1])+"</span>"
        if current_user.has_role? :canceller
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',null,null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-success btn-xs' data-original-title='Retroceder el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_prev_state(dos[1].to_s)+"'},null,'GET') rel='tooltip'><i class='fa fa-mail-reply'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/purchase_orders/"+dos[0].to_s+"/purchase_order_pdf.pdf?company_id="+get_company_cost_center('company').to_s+"' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-danger btn-xs' data-original-title='Anular' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'canceled'},null,'GET') rel='tooltip'><i class='fa fa-times'></i></a>"
        else
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',null,null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-success btn-xs' data-original-title='Retroceder el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/purchase_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_prev_state(dos[1].to_s)+"'},null,'GET') rel='tooltip'><i class='fa fa-mail-reply'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/purchase_orders/"+dos[0].to_s+"/purchase_order_pdf.pdf?company_id="+get_company_cost_center('company').to_s+"' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>"
        end
      end

      if dos[2].nil?
        @description = "No se tiene una descripción"
      else
        @description = dos[2]
      end

      pur = PurchaseOrder.find(dos[0])
      if pur.state_per_order_purchases.last != nil
        @last_state_date = pur.state_per_order_purchases.last.created_at.strftime("%d/%m/%Y")
      else
        @last_state_date = pur.created_at.strftime("%d/%m/%Y")
      end

      array << [dos[6].to_s.rjust(5, '0'),@state,@description.to_s,dos[3].to_s,@last_state_date.to_s ,dos[4].strftime("%d/%m/%Y").to_s,dos[5], @action]
    end
    render json: { :aaData => array }
  end

  def more_items_from_delivery_orders
    @cost_center = CostCenter.find(get_company_cost_center('cost_center'))
    @deliveryOrders = Array.new

    @cost_center.delivery_orders.where("state LIKE 'approved'").each do |deo|
      if deo.delivery_order_details.where(:requested => nil).count > 0
        @deliveryOrders << deo
      end
    end

    render(partial: 'modal_more_items_delivery', :layout => false)
  end

  def showing_delivery_orders_table_result
    @delivery_orders_detail = Array.new
    @reg_n = ((Time.now.to_f)*100).to_i
    delivery_order_id = params[:delivery_orders]

    DeliveryOrder.where(:id => delivery_order_id).where(:state => 'approved').each do |deo|
      deo.delivery_order_details.where(:requested => nil).each do |dodw|
        @delivery_orders_detail << dodw
      end
    end

    render(partial: 'table_result_delivery_orders', :layout => false)
  end

  # BEGIN Extra Operations

  def add_modal_extra_operations
    @modals = params[:ids_delivery_order]
    @extra_calculations = ExtraCalculation.all
    render(partial: 'extra_op', :layout => false)
  end

  def add_more_row_form_extra_op
    @reg_n = ((Time.now.to_f)*100).to_i
    @concept = params[:concept ]
    @type = params[:type]
    @value = params[:value]
    @apply = params[:apply]
    @operation = params[:operation]

    @reg_main = params[:reg_n]
    @name_concept = params[:name_concept]
    @name_type = params[:name_type]
    @name_apply = params[:name_apply]
    

    render(partial: 'extra_op_form', :layout => false)
  end

  # END Extra Operation

  def create
    @purchaseOrder = PurchaseOrder.new(purchase_order_parameters)
    @purchaseOrder.state = 'pre_issued'
    @purchaseOrder.user_id = current_user.id
    if @purchaseOrder.save

      @purchaseOrder.purchase_order_details.each do |pod|
        dod_id = pod.delivery_order_detail_id
        sql_purchase_order_partial_amount = PurchaseOrder.get_total_amount_items_requested_by_purchase_order(dod_id)
        sql_delivery_order_total_amount = PurchaseOrder.get_total_amount_per_delivery_order(dod_id)

        if sql_purchase_order_partial_amount.first == sql_delivery_order_total_amount.first
          @deliveryOrderDetail = DeliveryOrderDetail.find(dod_id)
          @deliveryOrderDetail.update_attributes(:requested => 1)
        end
      end

      flash[:notice] = "Se ha creado correctamente la nueva orden de compra."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      @purchaseOrder.errors.messages.each do |attribute, error|
        puts attribute
        puts error
      end
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def update
    purchaseOrder = PurchaseOrder.find(params[:id])
    purchaseOrder.update_attributes(purchase_order_parameters)
    PurchaseOrder.find(purchaseOrder.id).purchase_order_details.each do |po|
      detail = PurchaseOrderDetail.find(po.id)
      discounts_before = 0
      discounts_after = 0
      po.purchase_order_extra_calculations.where("apply LIKE '%before%'").each do |pod|
        if pod.type =="percent"
          if pod.operation == "sum"
            discounts_before += (pod.value.to_f/100*(-1))*po.amount.to_f*po.unit_price.to_f
          else
            discounts_before += pod.value.to_f/100*po.amount.to_f*po.unit_price.to_f
          end
        elsif pod.type == "soles"
          if pod.operation == "sum"
            discounts_before += pod.value.to_f *(-1)
          else
            discounts_before += pod.value.to_f
          end
        end
      end
      igv = 0
      if po.igv
        igv = 0.18 
      end
      po.purchase_order_extra_calculations.where("apply LIKE '%after%'").each do |pod|
        if pod.type =="percent"
          if pod.operation == "sum"
            discounts_after += (pod.value.to_f/100*(-1))*((po.amount.to_f*po.unit_price.to_f-discounts_before.to_f)*(1+igv.to_f))
          else
            discounts_after += pod.value.to_f/100*((po.amount.to_f*po.unit_price.to_f-discounts_before.to_f)*(1+igv.to_f))
          end
        elsif pod.type == "soles"
          if pod.operation == "sum"
            discounts_after += pod.value.to_f *(-1)
          else
            discounts_after += pod.value.to_f
          end
        end
      end
      detail.update_attributes(:discount_before=>discounts_before, :discount_after=>discounts_after, :quantity_igv=>((po.amount.to_f*po.unit_price.to_f-discounts_before.to_f)*(igv.to_f)), :unit_price_before_igv=>(po.amount.to_f*po.unit_price.to_f- discounts_before.to_f), :unit_price_igv => (((po.amount.to_f*po.unit_price.to_f-discounts_before.to_f)*(1+igv.to_f))- discounts_after.to_f))
    end
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index, company_id: params[:company_id]
  rescue ActiveRecord::StaleObjectError
    purchaseOrder.reload
    flash[:error] = "Alguien más ha modificado los datos en este instante. Intente Nuevamente."
    redirect_to :action => :index, company_id: params[:company_id]
  end

  # DO DELETE row
  def delete
    @purchaseOrder = PurchaseOrder.find(params[:id])
    if !PurchaseOrder.inspect_have_data(params[:id])
      @purchaseOrder = PurchaseOrder.destroy(params[:id])
      @purchaseOrder.purchase_order_details.each do |pod|
        PurchaseOrderDetail.destroy(pod.id)
      end
    else
      flash[:error] = "La Orden de Compra N° " + @purchaseOrder.id.to_s.rjust(5, '0') + " no puede ser eliminada."
    end
    render :json => @purchaseOrder
  end

  # Este es el cambio de estado
  def destroy
    @purchaseOrder = PurchaseOrder.find_by_id(params[:id])
    if !PurchaseOrder.inspect_have_data(params[:id])
      if @purchaseOrder.cancel!
        stateOrderDetail = StatePerOrderPurchase.new
        stateOrderDetail.state = @purchaseOrder.human_state_name
        stateOrderDetail.purchase_order_id = params[:id]
        stateOrderDetail.user_id = current_user.id
        stateOrderDetail.save
      end
    else
      flash[:error] = "La Orden de Compra N° " + @purchaseOrder.id.to_s.rjust(5, '0') + " no puede ser cancelada. Los datos de esta orden están siendo utilizados."
    end
    #redirect_to :action => :index, company_id: params[:company_id]
    render :json => @purchaseOrder
  end

  def goissue
    @purchaseOrder = PurchaseOrder.find_by_id(params[:id])
    if @purchaseOrder.issue!
      stateOrderDetail = StatePerOrderPurchase.new
      stateOrderDetail.state = @purchaseOrder.human_state_name
      stateOrderDetail.purchase_order_id = params[:id]
      stateOrderDetail.user_id = current_user.id
      stateOrderDetail.save
    end
    redirect_to :action => :index
  end

  def gorevise
    @purchaseOrder = PurchaseOrder.find_by_id(params[:id])
    if @purchaseOrder.revise!
      stateOrderDetail = StatePerOrderPurchase.new
      stateOrderDetail.state = @purchaseOrder.human_state_name
      stateOrderDetail.purchase_order_id = params[:id]
      stateOrderDetail.user_id = current_user.id
      stateOrderDetail.save
    end
    if params[:flag] == ''
      redirect_to :action => :index
    else
      redirect_to inbox_task_main_path
    end
  end

  def goapprove
    @purchaseOrder = PurchaseOrder.find_by_id(params[:id])
    if @purchaseOrder.approve!
      stateOrderDetail = StatePerOrderPurchase.new
      stateOrderDetail.state = @purchaseOrder.human_state_name
      stateOrderDetail.purchase_order_id = params[:id]
      stateOrderDetail.user_id = current_user.id
      stateOrderDetail.save
    end
    if params[:flag] == ''
      redirect_to :action => :index
    else
      redirect_to inbox_task_main_path
    end
  end

  def goobserve
    @purchaseOrder = PurchaseOrder.find_by_id(params[:id])
    if @purchaseOrder.observe!
      stateOrderDetail = StatePerOrderPurchase.new
      stateOrderDetail.state = @purchaseOrder.human_state_name
      stateOrderDetail.purchase_order_id = params[:id]
      stateOrderDetail.user_id = current_user.id
      stateOrderDetail.save
    end
    redirect_to :action => :index
  end

  def purchase_order_pdf
    @company = Company.find(params[:company_id])
    @purchaseOrder = PurchaseOrder.find(params[:id])
    @cc = CostCenter.find(get_company_cost_center('cost_center'))
    @purchaseOrderDetails = @purchaseOrder.purchase_order_details
    aux = 0
    @deliveryOrders = Array.new

    # Operations after IGV
    

    @purchaseOrder.purchase_order_details.each do |pod|
      current_id = pod.delivery_order_detail.delivery_order.id
      if aux != current_id
        aux = current_id
        @deliveryOrders << current_id.to_s.rjust(5, '0')
      end
    end
    
    # Numerics/Text values for footer
    @total = 0
    @igv = 0
    @igv_neto = 0

    FinancialVariable.where("name LIKE '%IGV%'").each do |val|
      if val != nil
        @igv= val.value.to_f
      else
        @igv = 0.18
      end
    end

    @purchaseOrderDetails.each do |pod|
      @total += pod.unit_price_before_igv.to_f.round(2)
      @igv_neto += (pod.unit_price_before_igv.to_f*@igv).round(7).round(6).round(5).round(4).round(3).round(2)
      #puts '----------------'
      #puts 'Antes de IGV: ' + pod.unit_price_before_igv.to_f.to_s
      #puts 'Antes X IGV: ' + (pod.unit_price_before_igv.to_f * @igv).round(7).round(6).round(5).round(4).round(3).round(2).to_s
      #puts '----------------'
    end

    puts '----------------'
    puts @igv_neto
    puts '----------------'

    @percepcion_neto=0
    @descuento_neto=0
    @cargo_neto=0
    @otro_neto=0
    #@igv_neto = @total*@igv
    @total_neto = @total + @igv_neto

    @perceptions = ActiveRecord::Base.connection.execute("SELECT d.discount_after FROM purchase_order_details d,purchase_order_extra_calculations e  WHERE d.purchase_order_id ="+@purchaseOrder.id.to_s+" AND e.purchase_order_detail_id=d.id AND e.extra_calculation_id=2")
    @perceptions.each do |p|
      @percepcion_neto+=p[0].to_f
    end

    @discounts = ActiveRecord::Base.connection.execute("SELECT d.discount_after FROM purchase_order_details d,purchase_order_extra_calculations e  WHERE d.purchase_order_id ="+@purchaseOrder.id.to_s+" AND e.purchase_order_detail_id=d.id AND e.extra_calculation_id=1")
    @discounts.each do |p|
      @descuento_neto+=p[0].to_f
    end

    @charges = ActiveRecord::Base.connection.execute("SELECT d.discount_after FROM purchase_order_details d,purchase_order_extra_calculations e  WHERE d.purchase_order_id ="+@purchaseOrder.id.to_s+" AND e.purchase_order_detail_id=d.id AND e.extra_calculation_id=3")
    @charges.each do |p|
      @cargo_neto+=p[0].to_f
    end

    @others = ActiveRecord::Base.connection.execute("SELECT d.discount_after FROM purchase_order_details d,purchase_order_extra_calculations e  WHERE d.purchase_order_id ="+@purchaseOrder.id.to_s+" AND e.purchase_order_detail_id=d.id AND e.extra_calculation_id=4")
    @others.each do |p|
      @otro_neto+=p[0].to_f
    end

    if @purchaseOrder.state == 'pre_issued'
      @state_per_order_purchase_approved = @purchaseOrder.state_per_order_purchases.where("state LIKE 'pre_issued'").last
      @state_per_order_purchase_revised = @purchaseOrder.state_per_order_purchases.where("state LIKE 'pre_issued'").last

      if @state_per_order_purchase_approved == nil && @state_per_order_purchase_revised == nil
        @state_per_order_purchase_approved = @purchaseOrder
        @state_per_order_purchase_revised = @purchaseOrder
      end

      @first_state = "Pre-Emitido"
      @second_state = "Pre-Emitido"
    end

    if @purchaseOrder.state == 'issued'
      @state_per_order_purchase_approved = @purchaseOrder.state_per_order_purchases.where("state LIKE 'issued'").last
      @state_per_order_purchase_revised = @purchaseOrder.state_per_order_purchases.where("state LIKE 'pre_issued'").last
      @first_state = "Emitido"
      @second_state = "Pre-Emitido"
    end

    if @purchaseOrder.state == 'revised'
      @state_per_order_purchase_approved = @purchaseOrder.state_per_order_purchases.where("state LIKE 'revised'").last
      @state_per_order_purchase_revised = @purchaseOrder.state_per_order_purchases.where("state LIKE 'issued'").last
      @first_state = "Revisado"
      @second_state = "Emitido"
    end

    if @purchaseOrder.state == 'approved'
      @state_per_order_purchase_approved = @purchaseOrder.state_per_order_purchases.where("state LIKE 'approved'").last
      @state_per_order_purchase_revised = @purchaseOrder.state_per_order_purchases.where("state LIKE 'revised'").last
      @first_state = "Aprobado"
      @second_state = "Revisado"
    end

    if @purchaseOrder.state == 'canceled'
      @state_per_order_purchase_approved = @purchaseOrder.state_per_order_purchases.where("state LIKE 'canceled'").last
      @state_per_order_purchase_revised = @purchaseOrder.state_per_order_purchases.where("state LIKE 'canceled'").last
      @first_state = "Cancelado"
      @second_state = "Cancelado"
    end

    prawnto inline: true, :prawn => { :page_size => 'A4', :page_layout => :landscape }

  end

  def get_exchange_rate_per_date
    render :json => exchange_rate_per_date(params[:date], params[:money_id]).first()
  end

  private
  def purchase_order_parameters
    params.require(:purchase_order).permit(
      :code,
      :exchange_of_rate, 
      :date_of_issue, 
      :expiration_date, 
      :delivery_date, 
      :lock_version,
      :retention, 
      :money_id, 
      :method_of_payment_id, 
      :entity_id, 
      :cost_center_id, 
      :state, 
      :description, 
      purchase_order_details_attributes: [
        :id,
        :discount_before_percent,
        :number_of_guide,
        :purchase_order_id, 
        :delivery_order_detail_id, 
        :unit_price, 
        :igv, 
        :amount, 
        :lock_version,
        :unit_price_before_igv, 
        :unit_price_igv, 
        :discount_before, 
        :discount_after, 
        :quantity_igv,
        :description, 
        :_destroy,
        purchase_order_extra_calculations_attributes: [
          :id,
          :purchase_order_detail_id,
          :extra_calculation_id,
          :value,
          :apply,
          :operation,
          :type,
          :_destroy
        ]
      ]
    )
  end
end
