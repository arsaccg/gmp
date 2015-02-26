class Logistics::ReportStocksController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  skip_before_filter  :verify_authenticity_token
  def index
    @articleresult = get_report()
    render layout: false
  end

  def show_articles
    display_length = params[:iDisplayLength]
    pager_number = params[:iDisplayStart]
    keyword = params[:sSearch]
    array = Array.new
    cost_center = get_company_cost_center('cost_center')
    array = ReportStock.get_articles(cost_center, display_length, pager_number, keyword)
    render json: { :aaData => array }
  end

  def excel_stock
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => 'Reporte de Stock'
    @articleresult = get_report()
    format = Spreadsheet::Format.new :weight => :bold, :size => 8, :align => :center
    sheet1.row(0).default_format = format
    sheet1.column(0).width = 60
    sheet1.column(1).width = 13
    sheet1.column(2).width = 35
    sheet1.column(3).width = 11
    sheet1.column(4).width = 11
    sheet1.row(0).replace [ 'Almacen', 'Código', 'Nombre', 'Cantidad', 'UND' ]
    @row = 1
    @articleresult.each do |artr|
      @stock = artr[9] - artr[12]
      sheet1.row(@row).replace [ artr[1], artr[6], artr[7], @stock, artr[8] ]
      @row += 1
    end
    book.write 'excelfile.xls'
    redirect_to :action => :index, company_id: session[:company]
    #export_file_path = [Rails.root, "public", "reporte_de_stock_#{ DateTime.now.to_s }.xls"].join("/")
    #book.write export_file_path
    #send_file export_file_path, :content_type => "application/vnd.ms-excel", :disposition => 'inline'

  end

  def report_stock_pdf
    @date = Time.now
    @costcenter = CostCenter.find(session[:cost_center]).name
    @articleresult = get_report()
    prawnto inline: true, :prawn => { :page_size => 'A4', :page_layout => :portrait }

  end

  def get_report
    
    @company = get_company_cost_center('company')
    @cost_center = get_company_cost_center('cost_center')
    @user = current_user.id
    @report_type = 4 #Normal
    @date_type = "1" #Kárdex E/S
    @since_date = Date.strptime("01/01/1900", '%d/%m/%Y')
    @to_date = Date.strptime("31/12/2050", '%d/%m/%Y')

    @articleresult = StockInputDetail.get_kardex_summary(1, @company, @cost_center, @user, @report_type, @date_type, @since_date, @to_date, '', '', '', '', '', '', '', '')
    
    return @articleresult

/
    article = Array.new

    result = 0.0
    name = ""
    articleresult = Array.new
    sum = 0
    rest = 0
    stockinput = StockInput.where("cost_center_id = ?", session[:cost_center])
    stockinput.each do |sis2|
      sis2.stock_input_details.each do |sisd2|
        article << sisd2.article_id
      end
    end
    article = article.uniq
    article.each do |art|
      name = Article.find(art).name
      code = Article.find(art).code
      unit = Article.find(art).unit_of_measurement.symbol
      sisum = StockInput.where("input = 1 and cost_center_id = ?", session[:cost_center])
      sisum.each do |sis|
        sis.stock_input_details.each do |sisd|
          if sisd.article_id == art
            sum += sisd.amount
          end
        end
      end
      sires = StockInput.where("input = 0")
      sires.each do |sir|
        sir.stock_input_details.each do |sird|
          if sird.article_id == art
            rest += sird.amount
          end
        end
      end
      result = sum - rest
      sum = 0
      rest = 0
      articleresult << [code,name,result,unit]
    end
    return articleresult

/
  end

end