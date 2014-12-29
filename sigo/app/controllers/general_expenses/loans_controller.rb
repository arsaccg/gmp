class GeneralExpenses::LoansController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def new
    @costcenters = CostCenter.where('id not in (?)', params[:cc_id])
    @cc = CostCenter.find(params[:cc_id]) rescue nil
    @loan = Loan.new
    render layout: false
  end

  def create

  end

  def create_loan
    flash[:error] = nil
    loan = Loan.new
    loan.person = params[:person]
    loan.loan_date = params[:loan_date]
    loan.loan_type = params[:loan_type]
    loan.amount = params[:amount]
    loan.description = params[:description]
    loan.refund_type = params[:refund_type]
    loan.check_number = params[:check_number]
    loan.check_date = params[:check_date]
    loan.state = params[:state]
    loan.refund_date = params[:refund_date]
    loan.cost_center_beneficiary_id = params[:cost_center_beneficiary_id]
    loan.cost_center_lender_id = params[:cost_center_lender_id]
    if loan.save
      loan.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
    end
    render json: {:cc_id=>loan.cost_center_lender_id.to_s}
  end

  def update
    loan = Loan.find(params[:id])
    if loan.update_attributes(loan_params)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, :controller => "loans"
    else
      con.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @loan = loan
      render :edit, layout: false
    end
  end

  def display_workers
    if params[:element].nil?
      word = params[:q]
    else
      word = params[:element]
    end
    workers_hash = Array.new
    if params[:element].nil?
      workers = ActiveRecord::Base.connection.execute("
        SELECT w.id,  e.name, e.paternal_surname, e.maternal_surname, e.dni
        FROM workers w, entities e
        WHERE ( e.name LIKE '%#{word}%' || e.paternal_surname LIKE '%#{word}%' || e.maternal_surname LIKE '%#{word}%' || e.dni LIKE '%#{word}%')
        AND w.entity_id = e.id
        GROUP BY e.id"
          )      
    else
      workers = ActiveRecord::Base.connection.execute("
        SELECT w.id,  e.name, e.paternal_surname, e.maternal_surname, e.dni
        FROM workers w, entities e
        WHERE w.entity_id = e.id
        AND w.id = #{word}
        GROUP BY e.id"
          )
    end
    workers.each do |art|
      workers_hash << {'name' => art[1],"paternal_surname"=> art[2],"maternal_surname"=> art[3],"id"=> art[0],"dni"=> art[4]}
    end
    render json: {:workers => workers_hash}
  end

  def edit
    @cc1 = params[:cc1]
    @cc2 = params[:cc2]
    @cc3 = params[:cc3]

    @costcenters = CostCenter.all
    @loan = Loan.find(params[:id])

    @action = 'edit'
    render layout: false
  end

  def destroy
    loan = Loan.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el pedido seleccionado."
    render :json => loan
  end

  def index
    @cc = CostCenter.find(params[:cc_id])
    @presto = Loan.where('cost_center_lender_id=?', @cc.id)
    @prestaron = Loan.where('cost_center_beneficiary_id=?', @cc.id)
    @ledeben = Array.new
    @debe = Array.new
    ledeben = ActiveRecord::Base.connection.execute("
      SELECT cost_center_beneficiary_id
      FROM  loans
      WHERE  cost_center_lender_id ="+@cc.id.to_s+"
      GROUP BY cost_center_beneficiary_id
    ")
    ledeben.each do |ld|
      aldp=0
      aldd=0
      ldp = ActiveRecord::Base.connection.execute("
        SELECT Sum(amount)
        FROM  loans
        WHERE  cost_center_lender_id ="+@cc.id.to_s+"
        AND cost_center_beneficiary_id = "+ld[0].to_s+"
        AND state = 1
      ")
      ldp.each do |ldp|
        aldp=ldp[0]
      end
      ldd = ActiveRecord::Base.connection.execute("
        SELECT Sum(amount)
        FROM  loans
        WHERE  cost_center_lender_id ="+@cc.id.to_s+"
        AND cost_center_beneficiary_id = "+ld[0].to_s+"
        AND state = 2
      ")
      ldd.each do |ldp|
        aldd=ldp[0]
      end
      @ledeben << [ld[0].to_s,aldp,aldd]
    end

    debe = ActiveRecord::Base.connection.execute("
      SELECT cost_center_lender_id
      FROM  loans
      WHERE  cost_center_beneficiary_id ="+@cc.id.to_s+"
      GROUP BY cost_center_lender_id
    ")

    debe.each do |ld|
      aldp=0
      aldd=0
      ldp = ActiveRecord::Base.connection.execute("
        SELECT Sum(amount)
        FROM  loans
        WHERE  cost_center_beneficiary_id ="+@cc.id.to_s+"
        AND cost_center_lender_id = "+ld[0].to_s+"
        AND state = 1
      ")
      ldp.each do |ldp|
        aldp=ldp[0]
      end
      ldd = ActiveRecord::Base.connection.execute("
        SELECT Sum(amount)
        FROM  loans
        WHERE  cost_center_beneficiary_id ="+@cc.id.to_s+"
        AND cost_center_lender_id = "+ld[0].to_s+"
        AND state = 2
      ")
      ldd.each do |ldp|
        aldd=ldp[0]
      end
      @debe << [ld[0].to_s,aldp,aldd]
    end    
    render layout: false
  end

  def show
    @type = params[:type]
    @cost_center1 = CostCenter.find(params[:cc1])
    @cost_center2 = CostCenter.find(params[:cc2])
    @cc = params[:cc3]
    @loan = Loan.where("cost_center_lender_id = ? AND cost_center_beneficiary_id = ?",@cost_center1.id, @cost_center2.id)
    @total = 0
    @devuelto = 0
    @loan.each do |loan|
      @total+= loan.amount
      if loan.state == "2"
        @devuelto += loan.amount
      end
    end
    render layout: false
  end

  def show_details 
    @loan= Loan.find(params[:id])
    render(partial: 'show_detail', :layout => false)
  end  

  def report_pdf
    respond_to do |format|
      format.html
      format.pdf do
        @todo = Array.new
        @ccs = CostCenter.where("active = 1")
        @ccs.each do |cc|
          flag1 =true
          flag2 =true
          @array_le_deben = Array.new
          @array_debe = Array.new
          suma_total = 0
          suma_total_le_deben = 0
          suma_total_debe = 0
          lender = ActiveRecord::Base.connection.execute("
            SELECT cc.id, CONCAT(cc.code, ' - ', cc.name), SUM(l.amount)
            FROM loans l, cost_centers cc
            WHERE cost_center_lender_id ="+cc.id.to_s+"
            AND cost_center_beneficiary_id = cc.id
            GROUP BY cost_center_beneficiary_id
          ")
          lender.each do |l|
            suma_devuelto = 0
            suma_pendiente = 0
            suma_total += l[2].to_f
            montos = ActiveRecord::Base.connection.execute("            
              SELECT SUM(l.amount), l.state
              FROM loans l
              WHERE cost_center_lender_id = "+cc.id.to_s+"
              AND cost_center_beneficiary_id = "+l[0].to_s+"
              GROUP BY l.state
            ")
            montos.each do |m|
              if m[1].to_i == 2
                suma_devuelto+=m[0].to_f
              elsif m[1].to_i == 1
                suma_total_le_deben += m[0].to_f
                suma_pendiente += m[0].to_f
              end
            end
            @array_le_deben << [l[1].to_s, l[2].to_f, suma_devuelto.to_f, suma_pendiente.to_f, "lender_detail"]
          end
          
          beneficiary = ActiveRecord::Base.connection.execute("
            SELECT cc.id, CONCAT(cc.code, ' - ', cc.name), SUM(l.amount)
            FROM loans l, cost_centers cc
            WHERE cost_center_lender_id = cc.id
            AND cost_center_beneficiary_id = "+cc.id.to_s+"
            GROUP BY cost_center_lender_id
          ")          
          beneficiary.each do |b|
            suma_devuelto = 0
            suma_pendiente = 0
            suma_total -= b[2].to_f
            montos = ActiveRecord::Base.connection.execute("            
              SELECT SUM(l.amount), l.state
              FROM loans l
              WHERE cost_center_lender_id = "+b[0].to_s+"
              AND cost_center_beneficiary_id = "+cc.id.to_s+"
              GROUP BY l.state
            ")
            montos.each do |m|
              if m[1].to_i == 2
                suma_devuelto+=m[0].to_f
              elsif m[1].to_i == 1
                suma_total_debe += m[0].to_f
                suma_pendiente += m[0].to_f
              end
            end
            @array_debe << [b[1].to_s, b[2].to_f, suma_devuelto.to_f, suma_pendiente.to_f, "beneficiary_detail"]
          end          

          @todo << [cc.code+" - "+cc.name, suma_total, suma_total_le_deben, suma_total_debe, "main"]
          if lender.count != 0
            @todo << ["Centro de Costo Beneficiaro", "Total", "Devuelto", "Pendiente","lender_detail_header"]
            @todo += @array_le_deben
            flag1 = false
          end
          if beneficiary.count != 0
            @todo << ["Centro de Costo al que se debe", "Total", "Devuelto", "Pendiente","beneficiary_detail_header"]
            @todo += @array_debe
            flag2 = false
          end
          if flag1 && flag2
            @todo << ["NO SE REGISTRARON MOVIMIENTOS DE ESTE CENTRO DE COSTO "," "," "," ","blank2"]
          end
          @todo << [" "," "," "," ","blank"]
        end
        @todo.delete_at(@todo.length-1)

        render :pdf => "reporte_movimientos-#{Time.now.strftime('%d-%m-%Y')}", 
               :template => 'general_expenses/loans/report_pdf.pdf.haml',
               :orientation => 'Landscape',
               :page_size => 'A4'
      end
    end
  end

  def bidimensional_report_pdf
    respond_to do |format|
      format.html
      format.pdf do
        @todo = Array.new
        @ccs = CostCenter.all.order(:id)
        @todo << ["CUADRO COMPARATIVO"]
        i = 1
        @ccs.each do |ccr|
          @todo << [ccr.name]
          @ccs.each do |ccc|
            if ccr.id == ccc.id
              @todo[i] << "es el mismo"
              if !@todo[0].include?(ccc.name)
                @todo[0] << ccc.name.to_s
              end
            else
              lender_am = 0
              bene_am = 0
              if !@todo[0].include?(ccc.name)
                @todo[0] << ccc.name.to_s
              end
              lender = ActiveRecord::Base.connection.execute("
                SELECT SUM(l.amount)
                FROM loans l
                WHERE cost_center_lender_id ="+ccr.id.to_s+"
                AND cost_center_beneficiary_id = "+ccc.id.to_s+"
                AND state = 1
                GROUP BY cost_center_beneficiary_id
              ")
              if lender.count == 0
                lender_am = 0
              else
                lender_am = lender.first[0].to_f
              end
              beneficiary = ActiveRecord::Base.connection.execute("
                SELECT SUM(l.amount)
                FROM loans l
                WHERE cost_center_lender_id = "+ccc.id.to_s+"
                AND cost_center_beneficiary_id = "+ccr.id.to_s+"
                AND state = 1
                GROUP BY cost_center_beneficiary_id
              ")
              if beneficiary.count == 0
                bene_am = 0
              else
                bene_am = beneficiary.first[0]
              end
              diferencia = lender_am - bene_am
              @todo[i] << [lender_am.to_s , bene_am.to_s, diferencia.to_s]
            end
          end
          i+=1
        end   
        render :pdf => "reporte_movimientos-#{Time.now.strftime('%d-%m-%Y')}", 
               :template => 'general_expenses/loans/bidimensional_report_pdf.pdf.haml',
               :orientation => 'Landscape',
               :page_size => 'A4'
      end
    end
  end
  private
  def loan_params
    params.require(:loan).permit(:person,:loan_date,:loan_type,:amount,:description,:refund_type,:check_number,:check_date,:state,:refund_date,:cost_center_beneficiary_id,:cost_center_lender_id)
  end
end