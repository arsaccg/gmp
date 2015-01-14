class GeneralExpenses::GeneralExpensesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @gexp = GeneralExpense.where("cost_center_id = "+get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def show
    render layout: false
  end

  def get_report
    @phases = ActiveRecord::Base.connection.execute(" SELECT code_phase, SUM(total) FROM  general_expenses WHERE cost_center_id = "+get_company_cost_center('cost_center').to_s+" GROUP BY code_phase")
    @ccd = CostCenterDetail.find_by_cost_center_id(get_company_cost_center('cost_center').to_s)
    @cc = get_company_cost_center('cost_center').to_s
    @ge = GeneralExpense.where('cost_center_id = '+get_company_cost_center('cost_center').to_s)
    @ids = Array.new
    @t = Array.new
    @ge.each do |g|
      @ids << g.id
    end
    @ids=@ids.join(',')
    t=ActiveRecord::Base.connection.execute("
      SELECT SUM(ged.parcial) 
      FROM  general_expense_details ged
      WHERE ged.general_expense_id IN ("+@ids.to_s+")
    ")
    t.each do |t|
      @t = t[0]
    end
    render layout: false
  end
  
  def report
    @ccd = CostCenterDetail.find_by_cost_center_id(get_company_cost_center('cost_center').to_s)
    @cc = get_company_cost_center('cost_center').to_s
    @poe =ActiveRecord::Base.connection.execute("
      SELECT ge.code_phase, p.code, p.name, ge.total, ar.code, ar.name, u.name, ged.people, ged.participation, ged.time, ged.parcial, ged.amount, ged.cost
      FROM general_expense_details ged, general_expenses ge, articles ar, phases p, unit_of_measurements u
      WHERE ge.cost_center_id = "+@cc.to_s+"
      AND ge.id=ged.general_expense_id
      AND ar.id = ged.article_id
      AND p.id = ge.phase_id
      AND ar.unit_of_measurement_id = u.id
      ORDER BY p.code ASC 
    ")
    total = ActiveRecord::Base.connection.execute("
      SELECT SUM(total)
      FROM general_expenses
      WHERE cost_center_id = "+@cc.to_s+"
    ")
    @todo = Array.new
    @abuelo = Array.new
    @padre = Array.new
    @poe.each do |poe|
      if !@abuelo.include?(poe[0])
        suma = ActiveRecord::Base.connection.execute("
            SELECT SUM(total)
            FROM general_expenses
            WHERE cost_center_id = "+@cc.to_s+"
            AND code_phase = "+poe[0].to_s+"
          ")
        suma.each do |s|
          @sum=s[0]
        end
        @abuelo << poe[0]
        @todo << [poe[0],nil,Phase.find_by_code(poe[0].to_s).name.to_s,@sum.to_f,nil,nil,nil,nil,nil,nil,nil,nil,nil]
      end
      if !@padre.include?(poe[1])
        @padre << poe[1]
        @todo << [nil, poe[1],poe[2].to_s,poe[3],nil,nil,nil,nil,nil,nil,nil,nil,nil]
      end
      @todo << poe
    end
    total.each do |t|
      @total = t[0]
    end
    render :layout => false
  end

  def report_pdf
    respond_to do |format|
      format.html
      format.pdf do
        @ccd = CostCenterDetail.find_by_cost_center_id(get_company_cost_center('cost_center').to_s)
        @cc = get_company_cost_center('cost_center').to_s
        @poe =ActiveRecord::Base.connection.execute("
          SELECT ge.code_phase, p.code, p.name, ge.total, ar.code, ar.name, u.name, ged.people, ged.participation, ged.time, ged.parcial, ged.amount, ged.cost
          FROM general_expense_details ged, general_expenses ge, articles ar, phases p, unit_of_measurements u
          WHERE ge.cost_center_id = "+@cc.to_s+"
          AND ge.id=ged.general_expense_id
          AND ar.id = ged.article_id
          AND p.id = ge.phase_id
          AND ar.unit_of_measurement_id = u.id
          ORDER BY p.code ASC 
        ")
        total = ActiveRecord::Base.connection.execute("
          SELECT SUM(total)
          FROM general_expenses
          WHERE cost_center_id = "+@cc.to_s+"
        ")
        @todo = Array.new
        @abuelo = Array.new
        @padre = Array.new
        @poe.each do |poe|
          if !@abuelo.include?(poe[0])
            suma = ActiveRecord::Base.connection.execute("
                SELECT SUM(total)
                FROM general_expenses
                WHERE cost_center_id = "+@cc.to_s+"
                AND code_phase = "+poe[0].to_s+"
              ")
            suma.each do |s|
              @sum=s[0]
            end
            @abuelo << poe[0]
            @todo << [poe[0],nil,Phase.find_by_code(poe[0].to_s).name.to_s,@sum.to_f,nil,nil,nil,nil,nil,nil,nil,nil,nil]
          end
          if !@padre.include?(poe[1])
            @padre << poe[1]
            @todo << [nil, poe[1],poe[2].to_s,poe[3],nil,nil,nil,nil,nil,nil,nil,nil,nil]
          end
          @todo << poe
        end
        total.each do |t|
          @total = t[0]
        end
        render :pdf => "reporte_gastos_generales-#{Time.now.strftime('%d-%m-%Y')}", 
               :template => 'general_expenses/general_expenses/report_pdf.pdf.haml',
               :orientation => 'Landscape',
               :page_size => 'Letter'
      end
    end
  end


  def new
    @gexp = GeneralExpense.new
    @phase = Phase.where("code LIKE '____' AND code > '8999'").order(:code)
    @action = 'new'
    render layout: false
  end

  def display_articles
    word = params[:q]
    article_hash = Array.new
    articles = GeneralExpense.getOwnArticles(word)
    articles.each do |art|
      article_hash << {'id' => art[0].to_s+'-'+art[3].to_s+'-'+art[1].to_s, 'code' => art[1], 'name' => art[2], 'symbol' => art[4]}
    end
    render json: {:articles => article_hash}
  end

  def show_details 
    @type_01 = Array.new
    @t1 = 0
    @type_02 = Array.new
    @t2 = 0
    @type_03 = Array.new
    @t3 = 0
    @type_04 = Array.new
    @t4 = 0
    @type_05 = Array.new
    @t5 = 0
    @ge = GeneralExpense.find(params[:id])
    @ge.general_expense_details.each do |ged|
      if ged.type_article == "01"
        @type_01 << ged
        @t1 = @t1.to_f + ged.parcial.to_f
      elsif ged.type_article == "02"
        @type_02 << ged
        @t2 = @t2.to_f + ged.parcial.to_f
      elsif ged.type_article == "03"
        @type_03 << ged
        @t3 = @t3.to_f + ged.parcial.to_f
      elsif ged.type_article == "04"
        @type_04 << ged
        @t4 = @t4.to_f + ged.parcial.to_f
      else
        @type_05 << ged
        @t5 = @t5.to_f + ged.parcial.to_f
      end
    end
    render(partial: 'show_detail', :layout => false)
  end

  def create
    flash[:error] = nil
    gexp = GeneralExpense.new(gexp_parameters)
    gexp.code_phase = Phase.find(gexp.phase_id).code[0,2]
    gexp.cost_center_id = get_company_cost_center('cost_center').to_s
    if gexp.save
      @t=0
      t=ActiveRecord::Base.connection.execute("
        SELECT SUM(ged.parcial) 
        FROM  general_expense_details ged
        where ged.general_expense_id ="+gexp.id.to_s+"
      ")
      t.each do |t|
        @t = t[0]
      end
      ActiveRecord::Base.connection.execute("UPDATE general_expenses SET total='"+@t.to_s+"' WHERE id="+gexp.id.to_s)

      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      gexp.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @gexp = gexp
      render :new, layout: false 
    end
  end

  def edit
    @gexp = GeneralExpense.find(params[:id])
    @phase = Phase.where("code LIKE '____'")
    @reg_n = ((Time.now.to_f)*100).to_i
    @action = 'edit'
    render layout: false
  end

  def update
    gexp = GeneralExpense.find(params[:id])
    gexp.code_phase = Phase.find(gexp.phase_id).code[0,2]
    if gexp.update_attributes(gexp_parameters)
      @t=0
      t=ActiveRecord::Base.connection.execute("
        SELECT SUM(ged.parcial) 
        FROM  general_expense_details ged
        where ged.general_expense_id ="+gexp.id.to_s+"
      ")
      t.each do |t|
        @t = t[0]
      end
      ActiveRecord::Base.connection.execute("UPDATE general_expenses SET total='"+@t.to_s+"' WHERE id="+gexp.id.to_s)      
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      gexp.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @gexp = gexp
      render :edit, layout: false
    end
  end

  def destroy
    gexp = GeneralExpense.find(params[:id])
    gexp.general_expense_details.destroy_all
    gexp.destroy
    render :json => gexp
  end

  def add_concept
    @reg_n = ((Time.now.to_f)*100).to_i
    article = params[:article_id].split('-')
    @article = Article.find(article[0])
    @type = params[:type]
    render(partial: 'concepts', :layout => false)
  end

  private
  def gexp_parameters
    params.require(:general_expense).permit(:phase_id, :cost_center_id, 
      general_expense_details_attributes: [
        :id, 
        :general_expense_id, 
        :type_article,
        :article_id,
        :people,
        :participation,
        :time,
        :salary,
        :parcial,
        :amount,
        :cost,
        :depreciation,
        :useful_life,
        :price,
        :_destroy
      ])
  end
end