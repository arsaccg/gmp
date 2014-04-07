class Logistics::DocumentsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  def index
    flash[:error] = nil
    @items = Document.all #.where(company_id: "#{params[:company_id]}")
    render layout: false
  end

  def show
    render :json => nil
  end

  def new
    @document = Document.new
    @formats = Format.all
    # Lista de Formatos
    @formatList = Array.new
    render :new, layout: false
  end

  def create
    @action = 'create'
    flash[:error] = nil
    item = Document.new(item_parameters)
    item.user_inserts_id = current_user.id
    # Lista de Formatos
    @formatList = Array.new
    if params[:document_format] != nil
      params[:document_format]['format_id'].each.with_index(1) do |x, i|
        @formatList << [x.to_i]
      end
    end
    if item.update_attributes(item_parameters)
      #----------------------------
      # Format per Document
      #----------------------------
      if @formatList.count > 0
        @formatList.each do |x, i|
          y = FormatPerDocument.new
          y.update_attributes({document_id: item.id, format_id: x, user_inserts_id: current_user.id})
        end
      end
      flash[:notice] = "Se ha creado correctamente el registro."
      redirect_to :action => :index
    else
      #"Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      item.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @document = item
      @formats = Format.all
      render :new, layout: false
    end
        
  end

  def edit
    @action = 'edit'
    @document = Document.find(params[:id])
    @formats = Format.all
    @formatList = Array.new
    @document.format_per_documents.each do |x|
      @formatList << [x.format.id]
    end
    render layout: false
  end

  def update
    @action = 'edit'
    flash[:error] = nil
    item = Document.find(params[:id])
    item.user_updates_id = current_user.id
    # Lista de Formatos
    @formatList = Array.new
    if params[:document_format] != nil
      params[:document_format]['format_id'].each.with_index(1) do |x, i|
        @formatList << [x.to_i]
      end
    end
    # Update
    if item.update_attributes(item_parameters)
      #----------------------------
      # Format per Document
      #----------------------------
      if @formatList.count > 0
        # Active: Merge and New
        @formatList.each do |x, i|
          y = FormatPerDocument.unscoped.find_by_document_id_and_format_id(item.id, x)
          if y == nil
            FormatPerDocument.create(document_id: item.id, format_id: x, user_inserts_id: current_user.id)
          else
            if y.status != "A"
              y.update_attributes({status: "A", user_updates_id: current_user.id})
            end
          end
        end
        # Inactive: No Merge
        FormatPerDocument.unscoped.where(document_id: item.id).where.not(format_id: @formatList).each do |x|
          x.update_attributes({status: "D", user_updates_id: current_user.id})
        end
      else
        # Inactive: All Actives
        FormatPerDocument.where(document_id: item.id).each do |x|
          x.update_attributes({status: "D", user_updates_id: current_user.id})
        end
      end
      #----------------------------
      flash[:notice] = "Se ha actualizado correctamente el registro."
      redirect_to :action => :index
    else
      item.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @document = item
      @formats = Format.all
      render :edit, layout: false
    end
  end

  def destroy
    flash[:error] = nil
    item = Document.find(params[:id])
    item.update_attributes({status: "D", user_updates_id: params[:current_user_id]})
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => item
  end

  def save
    if valid?
      #save method implementation
      true
    else
      false
    end
  end

  private
  def item_parameters
    params.require(:document).permit(:name, :description)
  end
end
