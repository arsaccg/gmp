class Logistics::DeliveryOrdersController < ApplicationController
  include ApplicationHelper
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete], if: Proc.new { |c| c.request.format.json? }
  def index
    @article = Article.first
    @phase = Phase.first
    @sector = Sector.first
    @company = get_company_cost_center('company')
    @cost_center = get_company_cost_center('cost_center')
    @deliveryOrders = DeliveryOrder.where("cost_center_id = ?",@cost_center)
    @centerOfAttention = CenterOfAttention.where("cost_center_id = ?",@cost_center).first
    render layout: false
  end

  def display_articles
    word = params[:q]
    article_hash = Array.new
    @name = get_company_cost_center('cost_center')
    articles = DeliveryOrder.getOwnArticles(word, @name)
    articles.each do |art|
      article_hash << {'id' => art[0].to_s+'-'+art[3].to_s, 'code' => art[1], 'name' => art[2], 'symbol' => art[4]}
    end
    render json: {:articles => article_hash}
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
        de_o = ActiveRecord::Base.connection.execute("
          SELECT do.id, do.state, do.description, do.date_of_issue, do.scheduled,  CONCAT_WS(  ' ', u.first_name, u.last_name), do.code
          FROM delivery_orders do, users u
          WHERE do.cost_center_id = "+@cc.to_s+"
          AND do.user_id = u.id
          AND do.description LIKE '%#{keyword}%'
          ORDER BY do.id DESC
          LIMIT #{display_length}
          OFFSET #{pager_number}"
        )
      else
        de_o = ActiveRecord::Base.connection.execute("
          SELECT do.id, do.state, do.description, do.date_of_issue, do.scheduled,  CONCAT_WS(  ' ', u.first_name, u.last_name), do.code
          FROM delivery_orders do, users u
          WHERE do.cost_center_id = "+@cc.to_s+"
          AND do.user_id = u.id
          AND do.description LIKE '%#{keyword}%'
          AND do.state LIKE '"+state.to_s+"'
          ORDER BY do.id DESC
          LIMIT #{display_length}
          OFFSET #{pager_number}"
        )        
      end
    elsif @pagenumber == 'NaN'
      if state == ""
        de_o = ActiveRecord::Base.connection.execute("
          SELECT do.id, do.state, do.description, do.date_of_issue, do.scheduled,  CONCAT_WS(  ' ', u.first_name, u.last_name), do.code
          FROM delivery_orders do, users u
          WHERE do.cost_center_id = "+@cc.to_s+"
          AND do.user_id = u.id
          ORDER BY do.id DESC
          LIMIT #{display_length}"
        )
      else
        de_o = ActiveRecord::Base.connection.execute("
          SELECT do.id, do.state, do.description, do.date_of_issue, do.scheduled,  CONCAT_WS(  ' ', u.first_name, u.last_name), do.code
          FROM delivery_orders do, users u
          WHERE do.cost_center_id = "+@cc.to_s+"
          AND do.user_id = u.id
          AND do.state LIKE '"+state.to_s+"'
          ORDER BY do.id DESC
          LIMIT #{display_length}"
        )        
      end
    elsif keyword != ''
      if state == ""
        de_o = ActiveRecord::Base.connection.execute("
          SELECT do.id, do.state, do.description, do.date_of_issue, do.scheduled,  CONCAT_WS(  ' ', u.first_name, u.last_name), do.code
          FROM delivery_orders do, users u
          WHERE do.cost_center_id = "+@cc.to_s+"
          AND do.user_id = u.id
          ORDER BY do.id DESC"
        )
      else
        de_o = ActiveRecord::Base.connection.execute("
          SELECT do.id, do.state, do.description, do.date_of_issue, do.scheduled,  CONCAT_WS(  ' ', u.first_name, u.last_name), do.code
          FROM delivery_orders do, users u
          WHERE do.cost_center_id = "+@cc.to_s+"
          AND do.user_id = u.id
          AND do.state LIKE '"+state.to_s+"'
          ORDER BY do.id DESC"
        )        
      end
    else
      if state == ""
        de_o = ActiveRecord::Base.connection.execute("
          SELECT do.id, do.state, do.description, do.date_of_issue, do.scheduled,  CONCAT_WS(  ' ', u.first_name, u.last_name), do.code
          FROM delivery_orders do, users u
          WHERE do.cost_center_id = "+@cc.to_s+"
          AND do.user_id = u.id
          ORDER BY do.id DESC
          LIMIT #{display_length}
          OFFSET #{pager_number}"
        )
      else
        de_o = ActiveRecord::Base.connection.execute("
          SELECT do.id, do.state, do.description, do.date_of_issue, do.scheduled,  CONCAT_WS(  ' ', u.first_name, u.last_name), do.code
          FROM delivery_orders do, users u
          WHERE do.cost_center_id = "+@cc.to_s+"
          AND do.user_id = u.id
          AND do.state LIKE '"+state.to_s+"'
          ORDER BY do.id DESC
          LIMIT #{display_length}
          OFFSET #{pager_number}"
        )        
      end
    end
    de_o.each do |dos|
      @state = ""
      @action = ""
      case dos[1]
      when 'pre_issued'
        @state = "<i class='fa fa-flag' style='visibility: hidden;margin-right: 15px;'></i><span class='label' style='color: #000;'>"+translate_delivery_order_state(dos[1])+"</span>"
        if current_user.has_role? :canceller
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',null,null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-warning btn-xs' data-original-title='Editar' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"/edit','content',{company_id:"+get_company_cost_center('company').to_s+"},null,'GET') rel='tooltip'><i class='fa fa-edit'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_next_state(dos[1].to_s)+"'},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-danger btn-xs' data-original-title='Eliminar Orden' data-placement='top' onclick=javascript:delete_to_url('/logistics/delivery_orders/"+dos[0].to_s+"','content','/logistics/delivery_orders?company_id="+get_company_cost_center('company').to_s+"') rel='tooltip'><i class='fa fa-trash-o'></i></a>"
        else
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',null,null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-warning btn-xs' data-original-title='Editar' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"/edit','content',{company_id:"+get_company_cost_center('company').to_s+"},null,'GET') rel='tooltip'><i class='fa fa-edit'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_next_state(dos[1].to_s)+"'},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>"
        end

      when 'issued'
        @state = "<i class='fa fa-flag' style='color: #FF7A00;margin-right: 15px;'></i><span class='label label-warning' style='background-color: #FF7A00;'>"+translate_delivery_order_state(dos[1])+"</span>"
        if current_user.has_role? :canceller
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',null,null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-success btn-xs' data-original-title='Retroceder el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_prev_state(dos[1])+"'},null,'GET') rel='tooltip'><i class='fa fa-mail-reply'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_next_state(dos[1])+"'},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/delivery_orders/"+dos[0].to_s+"/delivery_order_pdf.pdf?company_id="+get_company_cost_center('company').to_s+"' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-danger btn-xs' data-original-title='Anular' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+", state_change:'canceled'},null,'GET') rel='tooltip'><i class='fa fa-times'></i></a>"
        else
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',null,null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-success btn-xs' data-original-title='Retroceder el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_prev_state(dos[1])+"'},null,'GET') rel='tooltip'><i class='fa fa-mail-reply'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_next_state(dos[1])+"'},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/delivery_orders/"+dos[0].to_s+"/delivery_order_pdf.pdf?company_id="+get_company_cost_center('company').to_s+"' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>"
        end

      when 'revised'
        @state = "<i class='fa fa-flag' style='color: #c79121;margin-right: 15px;'></i><span class='label label-warning'>"+translate_delivery_order_state(dos[1])+"</span>"
        if current_user.has_role? :canceller
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',null,null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-success btn-xs' data-original-title='Retroceder el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_prev_state(dos[1].to_s)+"'},null,'GET') rel='tooltip'><i class='fa fa-mail-reply'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_next_state(dos[1].to_s)+"'},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/delivery_orders/"+dos[0].to_s+"/delivery_order_pdf.pdf?company_id="+get_company_cost_center('company').to_s+"' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-danger btn-xs' data-original-title='Anular' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'canceled'},null,'GET') rel='tooltip'><i class='fa fa-times'></i></a>"
        else
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',null,null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-success btn-xs' data-original-title='Retroceder el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_prev_state(dos[1].to_s)+"'},null,'GET') rel='tooltip'><i class='fa fa-mail-reply'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_next_state(dos[1].to_s)+"'},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/delivery_orders/"+dos[0].to_s+"/delivery_order_pdf.pdf?company_id="+get_company_cost_center('company').to_s+"' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>"
        end

      when 'canceled'
        @state = "<i class='fa fa-flag' style='color: #a90329;margin-right: 15px;'></i><span class='label label-danger'>"+translate_delivery_order_state(dos[1])+"</span>"
        @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',null,null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/delivery_orders/"+dos[0].to_s+"/delivery_order_pdf.pdf?company_id="+get_company_cost_center('company').to_s+"' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>"

      when 'approved'
        @state= "<i class='fa fa-flag' style='color: #25CA25;margin-right: 15px;'></i><span class='label label-success' style='background-color: #25CA25;'>"+translate_delivery_order_state(dos[1])+"</span>"
        if current_user.has_role? :canceller
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',null,null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-success btn-xs' data-original-title='Retroceder el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_prev_state(dos[1].to_s)+"'},null,'GET') rel='tooltip'><i class='fa fa-mail-reply'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:''},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/delivery_orders/"+dos[0].to_s+"/delivery_order_pdf.pdf?company_id="+get_company_cost_center('company').to_s+"' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-danger btn-xs' data-original-title='Anular' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'canceled'},null,'GET') rel='tooltip'><i class='fa fa-times'></i></a>"
        else
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',null,null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-success btn-xs' data-original-title='Retroceder el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+", state_change:"+get_prev_state(dos[1].to_s)+"},null,'GET') rel='tooltip'><i class='fa fa-mail-reply'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/delivery_orders/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:''},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/delivery_orders/"+dos[0].to_s+"/delivery_order_pdf.pdf?company_id="+get_company_cost_center('company').to_s+"' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>" 
        end
      end

      array << [dos[6].to_s.rjust(5, '0'),@state,dos[2],dos[3].strftime("%d/%m/%Y").to_s,dos[4].strftime("%d/%m/%Y").to_s,dos[5], @action]
    end
    render json: { :aaData => array }
  end

  def new
    @company = params[:company_id]
    @cost_center = CostCenter.find(get_company_cost_center('cost_center'))
    @deliveryOrder = DeliveryOrder.new
    @last = DeliveryOrder.find(:last,:conditions => [ "cost_center_id = ?", @cost_center.id])
    if !@last.nil?
      @numbercode = @last.code.to_i+1
    else
      @numbercode = 1
    end
    @numbercode = @numbercode.to_s.rjust(5,'0')
    render layout: false
  end

  def create
    deliveryOrder = DeliveryOrder.new(delivery_order_parameters)
    deliveryOrder.state
    deliveryOrder.user_id = current_user.id
    if deliveryOrder.save
      flash[:notice] = "Se ha creado correctamente la nueva orden de suministro."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def show
    @company = params[:company_id]
    @deliveryOrder = DeliveryOrder.find(params[:id])
    if params[:state_change] != nil
      @state_change = params[:state_change]
      if params[:type_of_order] != nil
        @type_of_order = params[:type_of_order]
      end
    else
      @deliverPerState = @deliveryOrder.state_per_order_details
    end
    @deliveryOrderDetails = @deliveryOrder.delivery_order_details
    render layout: false
  end

  def edit
    @company = params[:company_id]
    @deliveryOrder = DeliveryOrder.find(params[:id])
    @sectors = Sector.where("cost_center_id = "+get_company_cost_center('cost_center').to_s)
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center'))
    @centerOfAttentions = CenterOfAttention.where("cost_center_id = ?",get_company_cost_center('cost_center'))
    @costcenter_id = @deliveryOrder.cost_center_id
    @action = 'edit'
    render layout: false
  end

  def update
    deliveryOrder = DeliveryOrder.find(params[:id])
    deliveryOrder.update_attributes(delivery_order_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index, company_id: params[:company_id]
  rescue ActiveRecord::StaleObjectError
      deliveryOrder.reload
      flash[:error] = "Alguien más ha modificado los datos en este instante. Intente Nuevamente."
      redirect_to :action => :index, company_id: params[:company_id]
  end

  def add_delivery_order_item_field
    @reg_n = ((Time.now.to_f)*100).to_i
    data_article_unit = params[:article_id].split('-')
    @article = Article.find_article_in_specific(data_article_unit[0], get_company_cost_center('cost_center'))
    @sectors = Sector.where("code LIKE '__' AND cost_center_id = "+get_company_cost_center('cost_center').to_s)
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center'))
    @quantity = params[:quantity].to_i
    @amount = params[:amount]
    @centerOfAttention= CenterOfAttention.where("cost_center_id = ?",get_company_cost_center('cost_center'))
    @article.each do |art|
      @code_article, @name_article, @id_article = art[3], art[1], art[2]
    end
    @unitOfMeasurement = UnitOfMeasurement.find(data_article_unit[1]).symbol
    @unitOfMeasurementId = data_article_unit[1]
    render(partial: 'delivery_order_items', :layout => false)
  end

  def show_tracking_orders
    @cost_center = get_company_cost_center('cost_center')
    @deliveryOrders = DeliveryOrder.where("cost_center_id = ? AND state LIKE ?", @cost_center, 'approved')
    render :tracing_orders, :layout => false
  end

  # DO DELETE row
  def delete
    @deliveryOrder = DeliveryOrder.find(params[:id])
    if !DeliveryOrder.inspect_have_data(params[:id])
      @deliveryOrder = DeliveryOrder.destroy(params[:id])
      @deliveryOrder.delivery_order_details.each do |dod|
        DeliveryOrderDetail.destroy(dod.id)
      end
    else
      flash[:error] = "La Orden de Servicio N° " + @deliveryOrder.id.to_s.rjust(5, '0') + " no puede ser eliminada. Los datos de esta orden están siendo utilizados."
    end
    render :json => @deliveryOrder
  end

  # Este es el cambio de estado
  def destroy
    @deliveryOrder = DeliveryOrder.find_by_id(params[:id])
    if !DeliveryOrder.inspect_have_data(params[:id])
      if @deliveryOrder.cancel
        stateOrderDetail = StatePerOrderDetail.new
        stateOrderDetail.state = @deliveryOrder.human_state_name
        stateOrderDetail.delivery_order_id = params[:id]
        stateOrderDetail.user_id = current_user.id
        stateOrderDetail.save
      end
    else
      flash[:error] = "La Orden de Servicio N° " + @deliveryOrder.id.to_s.rjust(5, '0') + " no puede ser eliminada. Los datos de esta orden están siendo utilizados."
    end
    #redirect_to :action => :index, company_id: params[:company_id]
    render :json => @deliveryOrder
  end

  def goissue
    @deliveryOrder = DeliveryOrder.find_by_id(params[:id])
    if @deliveryOrder.issue!
      stateOrderDetail = StatePerOrderDetail.new
      stateOrderDetail.state = @deliveryOrder.human_state_name
      stateOrderDetail.delivery_order_id = params[:id]
      stateOrderDetail.user_id = current_user.id
      stateOrderDetail.save
    end
    redirect_to :action => :index
  end

  def gorevise
    @deliveryOrder = DeliveryOrder.find_by_id(params[:id])
    if @deliveryOrder.revise!
      stateOrderDetail = StatePerOrderDetail.new
      stateOrderDetail.state = @deliveryOrder.human_state_name
      stateOrderDetail.delivery_order_id = params[:id]
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
    @deliveryOrder = DeliveryOrder.find_by_id(params[:id])
    if @deliveryOrder.approve!
      stateOrderDetail = StatePerOrderDetail.new
      stateOrderDetail.state = @deliveryOrder.human_state_name
      stateOrderDetail.delivery_order_id = params[:id]
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
    @deliveryOrder = DeliveryOrder.find_by_id(params[:id])
    if @deliveryOrder.observe!
      stateOrderDetail = StatePerOrderDetail.new
      stateOrderDetail.state = @deliveryOrder.human_state_name
      stateOrderDetail.delivery_order_id = params[:id]
      stateOrderDetail.user_id = current_user.id
      stateOrderDetail.save
    end
    redirect_to :action => :index
  end

  def delivery_order_pdf
    @company = Company.find(params[:company_id])
    @deliveryOrder = DeliveryOrder.find(params[:id])
    @cost_center_code = CostCenter.find(get_company_cost_center('cost_center')).code rescue 0000
    @deliveryOrderDetails = @deliveryOrder.delivery_order_details

    if @deliveryOrder.state == 'pre_issued'
      @state_per_order_details_approved = @deliveryOrder.state_per_order_details.where("state LIKE 'pre_issued'").last
      @state_per_order_details_revised = @deliveryOrder.state_per_order_details.where("state LIKE 'pre_issued'").last

      if @state_per_order_purchase_approved == nil && @state_per_order_purchase_revised == nil
        @state_per_order_purchase_approved = @deliveryOrder
        @state_per_order_purchase_revised = @deliveryOrder
      end

      @first_state = "Pre-Emitido"
      @second_state = "Pre-Emitido"
    end

    if @deliveryOrder.state == 'issued'
      @state_per_order_details_approved = @deliveryOrder.state_per_order_details.where("state LIKE 'issued'").last
      @state_per_order_details_revised = @deliveryOrder.state_per_order_details.where("state LIKE 'pre_issued'").last
      if @state_per_order_details_revised == nil
        @state_per_order_details_revised = @state_per_order_details_approved
      end
      @first_state = "Emitido"
      @second_state = "Pre-Emitido"
    end

    if @deliveryOrder.state == 'revised'
      @state_per_order_details_approved = @deliveryOrder.state_per_order_details.where("state LIKE 'revised'").last
      @state_per_order_details_revised = @deliveryOrder.state_per_order_details.where("state LIKE 'issued'").last
      @first_state = "Revisado"
      @second_state = "Emitido"
    end

    if @deliveryOrder.state == 'approved'
      @state_per_order_details_approved = @deliveryOrder.state_per_order_details.where("state LIKE 'approved'").last
      @state_per_order_details_revised = @deliveryOrder.state_per_order_details.where("state LIKE 'revised'").last
      @first_state = "Aprobado"
      @second_state = "Revisado"
    end

    if @deliveryOrder.state == 'canceled'
      @state_per_order_details_approved = @deliveryOrder.state_per_order_details.where("state LIKE 'canceled'").last
      @state_per_order_details_revised = @deliveryOrder.state_per_order_details.where("state LIKE 'canceled'").last
      @first_state = "Cancelado"
      @second_state = "Cancelado"
    end
    
  end

  private
  def delivery_order_parameters
    params.require(:delivery_order).permit(
      :code,
      :date_of_issue, 
      :scheduled, 
      :description, 
      :cost_center_id,
      :lock_version,
      delivery_order_details_attributes: [
        :id, 
        :delivery_order_id, 
        :article_id, 
        :unit_of_measurement_id, 
        :sector_id, 
        :phase_id, 
        :description, 
        :amount, 
        :scheduled_date,
        :lock_version, 
        :center_of_attention_id, 
        :_destroy
      ]
    )
  end
end
