class Logistics::OrderOfServicesController < ApplicationController
  include ApplicationHelper
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @article = Article.first
    @phase = Phase.first
    @sector = Sector.first
    @company = get_company_cost_center('company')
    @cost_center = get_company_cost_center('cost_center')
    @orderOfServices = OrderOfService.where("cost_center_id = ?", @cost_center)
    render layout: false
  end

  def display_articles
    word = params[:q]
    article_hash = Array.new
    @name = get_company_cost_center('cost_center')
    articles = OrderOfService.getOwnArticles(word, @name)
    articles.each do |art|
      article_hash << {'id' => art[0].to_s+'-'+art[3].to_s, 'code' => art[1], 'name' => art[2], 'symbol' => art[4]}
    end
    render json: {:articles => article_hash}
  end

  def display_orders
    @cc = get_company_cost_center('cost_center')
    @com = get_company_cost_center('company')
    display_length = params[:iDisplayLength]
    pager_number = params[:iDisplayStart]
    @pagenumber = params[:iDisplayStart]
    keyword = params[:sSearch]
    state = params[:state]

    array = Array.new
        
    if @pagenumber != 'NaN' && keyword != ''
      if state == ""
        os = ActiveRecord::Base.connection.execute("
          SELECT os.id, os.state, os.description, CONCAT_WS(  ' ', e.name, e.paternal_surname), os.date_of_issue, CONCAT_WS(  ' ', u.first_name, u.last_name), os.code
          FROM order_of_services os, users u, entities e
          WHERE os.cost_center_id = "+@cc.to_s+"
          AND os.user_id = u.id
          AND os.entity_id = e.id
          AND os.status = 1
          AND (os.description LIKE '%#{keyword}%' OR e.name LIKE '%#{keyword}%')
          ORDER BY os.id DESC
          LIMIT #{display_length}
          OFFSET #{pager_number}"
        )
      else
        os = ActiveRecord::Base.connection.execute("
          SELECT os.id, os.state, os.description, CONCAT_WS(  ' ', e.name, e.paternal_surname), os.date_of_issue, CONCAT_WS(  ' ', u.first_name, u.last_name), os.code
          FROM order_of_services os, users u, entities e
          WHERE os.cost_center_id = "+@cc.to_s+"
          AND os.user_id = u.id
          AND os.entity_id = e.id
          AND os.status = 1
          AND (os.description LIKE '%#{keyword}%' OR e.name LIKE '%#{keyword}%')
          AND os.state LIKE '"+state.to_s+"'
          ORDER BY os.id DESC
          LIMIT #{display_length}
          OFFSET #{pager_number}"
        )        
      end
    elsif @pagenumber == 'NaN'
      if state == ""
        os = ActiveRecord::Base.connection.execute("
          SELECT os.id, os.state, os.description, CONCAT_WS(  ' ', e.name, e.paternal_surname), os.date_of_issue, CONCAT_WS(  ' ', u.first_name, u.last_name), os.code
          FROM order_of_services os, users u, entities e
          WHERE os.cost_center_id = "+@cc.to_s+"
          AND os.user_id = u.id
          AND os.entity_id = e.id
          AND os.status = 1
          ORDER BY os.id DESC
          LIMIT #{display_length}"
        )
      else
        os = ActiveRecord::Base.connection.execute("
          SELECT os.id, os.state, os.description, CONCAT_WS(  ' ', e.name, e.paternal_surname), os.date_of_issue, CONCAT_WS(  ' ', u.first_name, u.last_name), os.code
          FROM order_of_services os, users u, entities e
          WHERE os.cost_center_id = "+@cc.to_s+"
          AND os.user_id = u.id
          AND os.entity_id = e.id
          AND os.state LIKE '"+state.to_s+"'
          AND os.status = 1
          ORDER BY os.id DESC
          LIMIT #{display_length}"
        )        
      end
    elsif keyword != ''
      if state == ""
        os = ActiveRecord::Base.connection.execute("
          SELECT os.id, os.state, os.description, CONCAT_WS(  ' ', e.name, e.paternal_surname), os.date_of_issue, CONCAT_WS(  ' ', u.first_name, u.last_name), os.code
          FROM order_of_services os, users u, entities e
          WHERE os.cost_center_id = "+@cc.to_s+"
          AND os.user_id = u.id
          AND os.entity_id = e.id
          AND os.status = 1
          ORDER BY os.id DESC"
        )
      else
        os = ActiveRecord::Base.connection.execute("
          SELECT os.id, os.state, os.description, CONCAT_WS(  ' ', e.name, e.paternal_surname), os.date_of_issue, CONCAT_WS(  ' ', u.first_name, u.last_name), os.code
          FROM order_of_services os, users u, entities e
          WHERE os.cost_center_id = "+@cc.to_s+"
          AND os.user_id = u.id
          AND os.state LIKE '"+state.to_s+"'
          AND os.entity_id = e.id
          AND os.status = 1
          ORDER BY os.id DESC"
        )
      end 
    else
      if state == ""
        os = ActiveRecord::Base.connection.execute("
          SELECT os.id, os.state, os.description, CONCAT_WS(  ' ', e.name, e.paternal_surname), os.date_of_issue, CONCAT_WS(  ' ', u.first_name, u.last_name), os.code
          FROM order_of_services os, users u, entities e
          WHERE os.cost_center_id = "+@cc.to_s+"
          AND os.user_id = u.id
          AND os.entity_id = e.id
          AND os.status = 1
          ORDER BY os.id DESC
          LIMIT #{display_length}
          OFFSET #{pager_number}
          "
        )
      else
        os = ActiveRecord::Base.connection.execute("
          SELECT os.id, os.state, os.description, CONCAT_WS(  ' ', e.name, e.paternal_surname), os.date_of_issue, CONCAT_WS(  ' ', u.first_name, u.last_name), os.code
          FROM order_of_services os, users u, entities e
          WHERE os.cost_center_id = "+@cc.to_s+"
          AND os.user_id = u.id
          AND os.entity_id = e.id
          AND os.state LIKE '"+state.to_s+"'
          AND os.status = 1
          ORDER BY os.id DESC
          LIMIT #{display_length}
          OFFSET #{pager_number}
          "
        )        
      end
    end
    os.each do |dos|
      @state = ""
      @action = ""
      case dos[1]
      when 'pre_issued'
        @state = "<i class='fa fa-flag' style='visibility: hidden;margin-right: 15px;'></i><span class='label' style='color: #000;'>"+translate_delivery_order_state(dos[1])+"</span>"
        if current_user.has_role? :canceller
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+@com.to_s+"},null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-warning btn-xs' data-original-title='Editar' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"/edit','content',{company_id:"+get_company_cost_center('company').to_s+"},null,'GET') rel='tooltip'><i class='fa fa-edit'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_next_state(dos[1].to_s)+"'},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-danger btn-xs' data-original-title='Eliminar Orden' data-placement='top' onclick=javascript:delete_to_url('/logistics/order_of_services/"+dos[0].to_s+"','content','/logistics/delivery_orders?company_id="+get_company_cost_center('company').to_s+"') rel='tooltip'><i class='fa fa-trash-o'></i></a>"
        else
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+@com.to_s+"},null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-warning btn-xs' data-original-title='Editar' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"/edit','content',{company_id:"+get_company_cost_center('company').to_s+"},null,'GET') rel='tooltip'><i class='fa fa-edit'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_next_state(dos[1].to_s)+"'},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>"
        end

      when 'issued'
        @state = "<i class='fa fa-flag' style='color: #FF7A00;margin-right: 15px;'></i><span class='label label-warning' style='background-color: #FF7A00;'>"+translate_delivery_order_state(dos[1])+"</span>"
        if current_user.has_role? :canceller
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+@com.to_s+"},null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-success btn-xs' data-original-title='Retroceder el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_prev_state(dos[1])+"'},null,'GET') rel='tooltip'><i class='fa fa-mail-reply'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_next_state(dos[1])+"'},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/order_of_services/"+dos[0].to_s+"/order_service_pdf.pdf?company_id="+get_company_cost_center('company').to_s+"' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-danger btn-xs' data-original-title='Anular' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+", state_change:'canceled'},null,'GET') rel='tooltip'><i class='fa fa-times'></i></a>"
        else
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+@com.to_s+"},null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-success btn-xs' data-original-title='Retroceder el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_prev_state(dos[1])+"'},null,'GET') rel='tooltip'><i class='fa fa-mail-reply'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_next_state(dos[1])+"'},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/order_of_services/"+dos[0].to_s+"/order_service_pdf.pdf?company_id="+get_company_cost_center('company').to_s+"' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>"
        end

      when 'revised'
        @state = "<i class='fa fa-flag' style='color: #c79121;margin-right: 15px;'></i><span class='label label-warning'>"+translate_delivery_order_state(dos[1])+"</span>"
        if current_user.has_role? :canceller
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+@com.to_s+"},null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-success btn-xs' data-original-title='Retroceder el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_prev_state(dos[1].to_s)+"'},null,'GET') rel='tooltip'><i class='fa fa-mail-reply'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_next_state(dos[1].to_s)+"'},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/order_of_services/"+dos[0].to_s+"/order_service_pdf.pdf?company_id="+get_company_cost_center('company').to_s+"' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-danger btn-xs' data-original-title='Anular' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'canceled'},null,'GET') rel='tooltip'><i class='fa fa-times'></i></a>"
        else
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+@com.to_s+"},null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-success btn-xs' data-original-title='Retroceder el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_prev_state(dos[1].to_s)+"'},null,'GET') rel='tooltip'><i class='fa fa-mail-reply'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_next_state(dos[1].to_s)+"'},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/order_of_services/"+dos[0].to_s+"/order_service_pdf.pdf?company_id="+get_company_cost_center('company').to_s+"' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>"
        end

      when 'canceled'
        @state = "<i class='fa fa-flag' style='color: #a90329;margin-right: 15px;'></i><span class='label label-danger'>"+translate_delivery_order_state(dos[1])+"</span>"
        @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+@com.to_s+"},null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/order_of_services/"+dos[0].to_s+"/order_service_pdf.pdf?company_id="+get_company_cost_center('company').to_s+"' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>"

      when 'approved'
        @state= "<i class='fa fa-flag' style='color: #25CA25;margin-right: 15px;'></i><span class='label label-success' style='background-color: #25CA25;'>"+translate_delivery_order_state(dos[1])+"</span>"
        if current_user.has_role? :canceller
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+@com.to_s+"},null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-success btn-xs' data-original-title='Retroceder el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'"+get_prev_state(dos[1].to_s)+"'},null,'GET') rel='tooltip'><i class='fa fa-mail-reply'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:''},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/order_of_services/"+dos[0].to_s+"/order_service_pdf.pdf?company_id="+get_company_cost_center('company').to_s+"' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-danger btn-xs' data-original-title='Anular' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:'canceled'},null,'GET') rel='tooltip'><i class='fa fa-times'></i></a>"
        else
          @action = "<a style='margin-right: 5px;' class='btn btn-view btn-xs' data-original-title='Ver Detalle' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+@com.to_s+"},null,'GET') rel='tooltip'><i class='fa fa-eye'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-success btn-xs' data-original-title='Retroceder el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+", state_change:"+get_prev_state(dos[1].to_s)+"},null,'GET') rel='tooltip'><i class='fa fa-mail-reply'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-info btn-xs' data-original-title='Avanzar el estado' data-placement='top' onclick=javascript:load_url_ajax('/logistics/order_of_services/"+dos[0].to_s+"','content',{company_id:"+get_company_cost_center('company').to_s+",state_change:''},null,'GET') rel='tooltip'><i class='fa fa-flag'></i></a>" + "<a style='margin-right: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/order_of_services/"+dos[0].to_s+"/order_service_pdf.pdf?company_id="+get_company_cost_center('company').to_s+"' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>" 
        end
      end
      if OrderOfService.find(dos[0]).state_per_order_of_services.count == 0
        @fecha = dos[4].strftime("%d/%m/%Y").to_s
      else
        @fecha = OrderOfService.find(dos[0]).state_per_order_of_services.last.created_at.strftime("%d/%m/%Y").to_s
      end
      array << [dos[6].to_s.rjust(5, '0'), @state, dos[2].to_s, dos[3].to_s, @fecha, dos[4].strftime("%d/%m/%Y").to_s, dos[5].to_s, @action]
    end
    render json: { :aaData => array }
  end

  def display_proveedor
    p "_--------------------------------------------------------------------------------------------------------------------------------------"
    p params[:element]
    if params[:element].nil?
      word = params[:q]
    else
      word = params[:element]
    end
    p word
    p "-----------------------------------------------------------------------------------------------------------------------------------------"
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

  def show
    @company = params[:company_id]
    @orderOfService = OrderOfService.find(params[:id])
    if params[:state_change] != nil
      @state_change = params[:state_change]
      if params[:type_of_order] != nil
        @type_of_order = params[:type_of_order]
      end
    else
      @orderOfServicePerState = @orderOfService.state_per_order_of_services
    end
    @orderOfServiceDetails = @orderOfService.order_of_service_details
    render layout: false
  end

  def new
    @company = get_company_cost_center('company')
    # Set default value
    @igv = 0.18+1
    @cost_center_id = get_company_cost_center('cost_center')
    @cost_center = CostCenter.find(@cost_center_id)
    @orderOfService = OrderOfService.new
    @last = OrderOfService.find(:last,:conditions => [ "cost_center_id = ?", @cost_center_id])
    if !@last.nil?
      @numbercode = @last.code.to_i+1
    else
      @numbercode = 1
    end
    @numbercode = @numbercode.to_s.rjust(5,'0')
    FinancialVariable.where("name LIKE '%IGV%'").each do |val|
      if val != nil
        @igv= val.value.to_f+1
      end
    end
    @methodOfPayments = MethodOfPayment.all
    TypeEntity.where("id = 1").each do |tent|
      @suppliers = tent.entities
    end
    @moneys = Money.all
    render layout: false
  end

  def create
    @orderOfService = OrderOfService.new(order_service_parameters)
    @orderOfService.state = 'pre_issued'
    @orderOfService.user_id = current_user.id
    if @orderOfService.save
      flash[:notice] = "Se ha creado correctamente la nueva orden de servicio."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def add_order_service_item_field
    cost_center_id = get_company_cost_center('cost_center')
    @reg_n = ((Time.now.to_f)*100).to_i
    data_article_unit = params[:article_id].split('-')
    @article = Article.find_article_in_specific(data_article_unit[0], get_company_cost_center('cost_center'))
    @sectors = Sector.where("code LIKE '__'AND cost_center_id = "+get_company_cost_center('cost_center').to_s)
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center'))
    @phases = @phases.sort! { |a,b| a.code <=> b.code }
    @amount = params[:amount].to_f
    @cc = get_company_cost_center('cost_center')
    @centerOfAttention = CenterOfAttention.all
    @unitOfMeasurement = UnitOfMeasurement.find(data_article_unit[1]).symbol
    @unitOfMeasurementId = data_article_unit[1]
    @working_groups = WorkingGroup.select(:id).select(:name).where(:cost_center_id => cost_center_id)
    @article.each do |art|
      @code_article, @name_article, @id_article = art[3], art[1], art[2]
    end
    render(partial: 'order_service_items', :layout => false)
  end

  def add_modal_extra_operations
    data_article_unit = params[:article_id].split('-')
    Article.find_article_in_specific(data_article_unit[0], get_company_cost_center('cost_center')).each do |art| 
      @id_article = art[2] 
    end
    @id_modal = 'modal-service-' + @id_article.to_s + '-' + params[:amount].to_s
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

  def edit
    @company = params[:company_id]
    @reg_n = ((Time.now.to_f)*100).to_i
    # Set default value
    @igv = 0.18+1
    @orderOfService = OrderOfService.find(params[:id])
    @sectors = Sector.where("cost_center_id = "+get_company_cost_center('cost_center').to_s)
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center'))
    @costcenters = Company.find(@company).cost_centers
    @methodOfPayments = MethodOfPayment.all
    @extra_calculations = ExtraCalculation.all
    @working_groups = WorkingGroup.all
    @cost_center_id = @orderOfService.cost_center_id
    FinancialVariable.where("name LIKE '%IGV%'").each do |val|
      if val != nil
        @igv= val.value.to_f+1
      end
    end
    TypeEntity.where("id = 1").each do |tent|
      @suppliers = tent.entities
    end
    @moneys = Money.all
    @action = 'edit'
    render layout: false
  end

  def update
    orderOfService = OrderOfService.find(params[:id])
    orderOfService.update_attributes(order_service_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index, company_id: params[:company_id]
  rescue ActiveRecord::StaleObjectError
    orderOfService.reload
    flash[:error] = "Alguien más ha modificado los datos en este instante. Intente Nuevamente."
    redirect_to :action => :index, company_id: params[:company_id]    
  end

  # Este es el cambio de estado
  def destroy
    @OrderOfService = OrderOfService.find_by_id(params[:id])
    @OrderOfService.cancel
    @OrderOfService.update(:status => 0, :date_of_elimination => Time.now)
    @OrderOfService.update(:user_id_historic => current_user.id)
    stateOrderDetail = StatePerOrderOfService.new
    stateOrderDetail.state = @OrderOfService.human_state_name
    stateOrderDetail.order_of_service_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    #redirect_to :action => :index, company_id: params[:company_id]
    render :json => @OrderOfService
  end

  def goissue
    @OrderOfService = OrderOfService.find_by_id(params[:id])
    @OrderOfService.issue
    stateOrderDetail = StatePerOrderOfService.new
    stateOrderDetail.state = @OrderOfService.human_state_name
    stateOrderDetail.order_of_service_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index, company_id: params[:company_id]
  end

  def gorevise
    @OrderOfService = OrderOfService.find_by_id(params[:id])
    @OrderOfService.revise
    stateOrderDetail = StatePerOrderOfService.new
    stateOrderDetail.state = @OrderOfService.human_state_name
    stateOrderDetail.order_of_service_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index, company_id: params[:company_id]
  end

  def goapprove
    @OrderOfService = OrderOfService.find_by_id(params[:id])
    @OrderOfService.approve
    stateOrderDetail = StatePerOrderOfService.new
    stateOrderDetail.state = @OrderOfService.human_state_name
    stateOrderDetail.order_of_service_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index, company_id: params[:company_id]
  end

  def goobserve
    @OrderOfService = OrderOfService.find_by_id(params[:id])
    @OrderOfService.observe
    stateOrderDetail = StatePerOrderOfService.new
    stateOrderDetail.state = @OrderOfService.human_state_name
    stateOrderDetail.order_of_service_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index, company_id: params[:company_id]
  end

  # DO DELETE row
  def delete
    @orderOfService = OrderOfService.destroy(params[:id])
    @orderOfService.order_of_service_details.each do |oos|
      OrderOfServiceDetail.destroy(oos.id)
    end
    render :json => @orderOfService
  end

  def order_service_pdf
    @company = Company.find(params[:company_id])
    @orderOfService = OrderOfService.find(params[:id])
    @orderServiceDetails = @orderOfService.order_of_service_details
    @cc = CostCenter.find(get_company_cost_center('cost_center'))
    # Numerics/Text values for footer
    @total = 0
    @igv = 0
    @igv_neto = 0
    @orderServiceDetails.each do |osd|
      @total += osd.amount.to_f*osd.unit_price.to_f
    end
    FinancialVariable.where("name LIKE '%IGV%'").each do |val|
      if val != nil
        @igv= val.value.to_f
      else
        @igv = 0.18
      end
    end
    @igv_neto = @total*@igv
    @total_neto = @total - @igv_neto

    if @orderOfService.state == 'pre_issued'
      @state_per_order_purchase_approved = @orderOfService.state_per_order_of_services.where("state LIKE 'pre_issued'").last
      @state_per_order_purchase_revised = @orderOfService.state_per_order_of_services.where("state LIKE 'pre_issued'").last

      if @state_per_order_purchase_approved == nil && @state_per_order_purchase_revised == nil
        @state_per_order_purchase_approved = @orderOfService
        @state_per_order_purchase_revised = @orderOfService
      end

      @first_state = "Pre-Emitido"
      @second_state = "Pre-Emitido"
    end

    if @orderOfService.state == 'issued'
      @state_per_order_purchase_approved = @orderOfService.state_per_order_of_services.where("state LIKE 'issued'").last
      @state_per_order_purchase_revised = @orderOfService.state_per_order_of_services.where("state LIKE 'pre_issued'").last
      @first_state = "Emitido"
      @second_state = "Pre-Emitido"
    end

    if @orderOfService.state == 'revised'
      @state_per_order_purchase_approved = @orderOfService.state_per_order_of_services.where("state LIKE 'revised'").last
      @state_per_order_purchase_revised = @orderOfService.state_per_order_of_services.where("state LIKE 'issued'").last
      @first_state = "Revisado"
      @second_state = "Emitido"
    end

    if @orderOfService.state == 'approved'
      @state_per_order_purchase_approved = @orderOfService.state_per_order_of_services.where("state LIKE 'approved'").last
      @state_per_order_purchase_revised = @orderOfService.state_per_order_of_services.where("state LIKE 'revised'").last
      @first_state = "Aprobado"
      @second_state = "Revisado"
    end

    if @orderOfService.state == 'canceled'
      @state_per_order_purchase_approved = @orderOfService.state_per_order_of_services.where("state LIKE 'canceled'").last
      @state_per_order_purchase_revised = @orderOfService.state_per_order_of_services.where("state LIKE 'canceled'").last
      @first_state = "Cancelado"
      @second_state = "Cancelado"
    end

    prawnto inline: true, :prawn => { :page_size => 'A4', :page_layout => :landscape }

  end

  private
  def order_service_parameters
    params.require(:order_of_service).permit(
      :code,
      :date_of_issue, 
      :date_of_service, 
      :method_of_payment_id, 
      :entity_id, 
      :cost_center_id, 
      :lock_version, 
      :money_id, 
      :exchange_of_rate, 
      :user_id, 
      :description, 
      order_of_service_details_attributes: [
        :id, 
        :order_of_service_id, 
        :article_id, 
        :unit_of_measurement_id, 
        :sector_id, 
        :phase_id, 
        :working_group_id,
        :unit_price, 
        :igv, 
        :lock_version, 
        :amount, 
        :unit_price_before_igv,
        :unit_price_igv, 
        :discount_after,
        :discount_before,
        :quantity_igv,
        :description, 
        :_destroy,
        order_service_extra_calculations_attributes: [
          :id,
          :order_of_service_detail_id,
          :extra_calculation_id, 
          :lock_version,
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
