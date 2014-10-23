class Administration::AccountAccountantsController < ApplicationController
  protect_from_forgery with: :null_session, :only => [:destroy]
  def index
    @accountAccountants = AccountAccountant.all
    render layout: false
  end

  def new
    @accountAccountant = AccountAccountant.new
    render :new, layout: false
  end

  def create
    accountAccountant = AccountAccountant.new(account_accountant_parameters)
    if accountAccountant.save
      flash[:notice] = "Se ha creado correctamente cuenta contable."
      redirect_to :action => :index
    else
      accountAccountant.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @accountAccountant = accountAccountant
      render :new, layout: false
    end
  end

  def edit
    @accountAccountant = AccountAccountant.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    accountAccountant = AccountAccountant.find(params[:id])
    if accountAccountant.update_attributes(account_accountant_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      accountAccountant.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @accountAccountant = accountAccountant
      render :edit, layout: false
    end
  end

  def display
    display_length = params[:iDisplayLength]
    pager_number = params[:iDisplayStart]
    @pagenumber = params[:iDisplayStart]
    keyword = params[:sSearch]
    state = params[:state]
    array = Array.new
    if @pagenumber != 'NaN' && keyword != ''
      @po = ActiveRecord::Base.connection.execute("
        SELECT id, code, name
        FROM account_accountants
        WHERE (id LIKE '%"+keyword.to_s+"%' OR code LIKE '%"+keyword.to_s+"%' OR name LIKE '%"+keyword.to_s+"%' )
        AND code NOT LIKE 'cod_ctacbl'
        ORDER BY code ASC
        LIMIT #{display_length}
        OFFSET #{pager_number}")
    elsif @pagenumber == 'NaN'
      @po = ActiveRecord::Base.connection.execute("
        SELECT id, code, name
        FROM account_accountants
        WHERE (id LIKE '%"+keyword.to_s+"%' OR code LIKE '%"+keyword.to_s+"%' OR name LIKE '%"+keyword.to_s+"%' )
        AND code NOT LIKE 'cod_ctacbl'
        ORDER BY code ASC
        LIMIT #{display_length}")
    elsif keyword != ''
      @po = ActiveRecord::Base.connection.execute("
        SELECT id, code, name
        FROM account_accountants
        WHERE code NOT LIKE 'cod_ctacbl'
        ORDER BY code ASC
        LIMIT #{display_length}")
    else
      @po = ActiveRecord::Base.connection.execute("
        SELECT id, code, name
        FROM account_accountants
        WHERE code NOT LIKE 'cod_ctacbl'
        ORDER BY code ASC
        LIMIT #{display_length}")      
    end

    @po.each do |dos|
      array << [dos[1].to_s,dos[2].to_s,"<a class='btn btn-warning btn-xs' onclick = javascript:load_url_ajax('/administration/account_accountants/"+dos[0].to_s+"/edit','content',null,null,'GET')> Editar </a> " + " <a class='btn btn-danger btn-xs' data-onclick=javascript:delete_to_url('/administration/account_accountants/"+dos[0].to_s+"','content','/administration/account_accountants') data-placement='left' data-popout='true' data-singleton='true' data-toggle='confirmation' data-title='Esta seguro de eliminar el item " + dos[2].to_s + "'  data-original-title='' title=''> Eliminar </a>"]
    end
    render json: { :aaData => array }
  end

  def destroy
    accountAccountant = AccountAccountant.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => accountAccountant
  end

  def import
    render layout: false
  end

  def do_import
    if !params[:file].nil?
      s = Roo::Excelx.new(params[:file].path,nil, :ignore)
      cantidad = s.count.to_i
      (1..cantidad).each do |fila|  
        codigo                =       s.cell('A',fila).to_s
        name               =       s.cell('B',fila).to_s

        if codigo.to_s != ''
          accountAccountant = AccountAccountant.new(:code => codigo, :name => name)
          accountAccountant.save!
        end        
      end
      redirect_to :action => :index
    else
      render :layout => false
    end
  end

  private
  def account_accountant_parameters
    params.require(:account_accountant).permit!
  end
end

