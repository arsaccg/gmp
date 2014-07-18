class Administration::AccountAccountantsController < ApplicationController
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
        codigo                =       s.cell('A',fila).to_s.to(1)
        name               =       s.cell('B',fila).to_s.to(1)

        if codigo.to_s != ''
          #accountAccountant = AccountAccountant.new(:code => codigo, :name => name)
          #accountAccountant.save
          puts "codigo: "+codigo
          puts "name: "+name
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

