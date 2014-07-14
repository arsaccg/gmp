class DocumentaryControl::PhotoOfWorksController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @photo = PhotoOfWork.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s).order(:created_at)
    render layout: false
  end

  def display_photos
    display_length = params[:iDisplayLength]
    pager_number = params[:iDisplayStart]
    @pagenumber = params[:iDisplayStart]
    keyword = params[:sSearch]
    array = Array.new

    if @pagenumber != 'NaN' && keyword != ''
      photos = ActiveRecord::Base.connection.execute("
        SELECT p.id, 
        p.name AS 'Nombre', 
        p.description AS 'Descripción', 
        p.photo AS 'Imagen'
        FROM photo_of_works p
        LIMIT #{display_length}
        OFFSET #{pager_number}"
      )
    elsif @pagenumber == 'NaN'
      photos = ActiveRecord::Base.connection.execute("
        SELECT p.id, 
        p.name AS 'Nombre', 
        p.description AS 'Descripción', 
        p.photo AS 'Imagen'
        FROM photo_of_works p
        ORDER BY p.id ASC
        LIMIT #{display_length}"
      )
    elsif keyword != ''
      photos = ActiveRecord::Base.connection.execute("
        SELECT p.id, 
        p.name AS 'Nombre', 
        p.description AS 'Descripción', 
        p.photo AS 'Imagen'
        FROM photo_of_works p
        AND p.name LIKE '%#{keyword}%'
        ORDER BY a.id ASC"
      )
    else
      photos = ActiveRecord::Base.connection.execute("
        SELECT p.id, 
        p.name AS 'Nombre', 
        p.description AS 'Descripción', 
        p.photo AS 'Imagen'
        FROM photo_of_works p
        ORDER BY p.id ASC
        LIMIT #{display_length}
        OFFSET #{pager_number}
        "
      )
    end
    photos.each do |photo|
      array << [photo[1],photo[2],photo[3],"<a class='btn btn-warning btn-xs' onclick = javascript:load_url_ajax('/documentary_control/photo_of_works/"+photo[0].to_s+"/edit','content',null,null,'GET')> Editar </a>" + "<a class='btn btn-danger btn-xs' data-onclick=javascript:delete_to_url('/documentary_control/photo_of_works/"+photo[0].to_s+"','content','/documentary_control/photo_of_works') data-placement='left' data-popout='true' data-singleton='true' data-toggle='confirmation' data-title='Esta seguro de eliminar el item " + photo[1].to_s + "'  data-original-title='' title=''> Eliminar </a>"]
    end
    render json: { :aaData => array }
  end

  def show
    @photo = PhotoOfWork.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s).order(:name)
    @photo = @photo.paginate(:page => params[:page], :per_page => 35)
    #respond_to do |format|
     # format.html
      #format.js
    #end
    render layout: false
  end

  def new
    @cost_center = get_company_cost_center('cost_center')
    @photo = PhotoOfWork.new
    render layout: false
  end

  def create
    flash[:error] = nil
    photo = PhotoOfWork.new(photo_parameters)
    photo.cost_center_id = get_company_cost_center('cost_center')
    if photo.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      photo.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @photo = photo
      render :new, layout: false 
    end
  end

  def edit
    @photo = PhotoOfWork.find(params[:id])
    @cost_center = get_company_cost_center('cost_center')
    @action = 'edit'
    render layout: false
  end

  def update
    photo = PhotoOfWork.find(params[:id])
    photo.cost_center_id = get_company_cost_center('cost_center')
    if photo.update_attributes(photo_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      photo.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @photo = photo
      render :edit, layout: false
    end
  end

  def destroy
    photo = PhotoOfWork.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => photo
  end

  private
  def photo_parameters
    params.require(:photo_of_work).permit(:name, :description, :photo)
  end
end