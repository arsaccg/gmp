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
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => 'Reporte de Stock'
    @articleresult = get_report()
    format = Spreadsheet::Format.new :weight => :bold, :size => 8, :align => :center
    sheet1.row(0).default_format = format
    sheet1.column(0).width = 13
    sheet1.column(1).width = 35
    sheet1.column(2).width = 11
    sheet1.row(0).replace [ 'Código', 'Nombre', 'Cantidad' ]
    @row = 1
    @articleresult.each do |artr|
      sheet1.row(@row).replace [ artr[0], artr[1], artr[2] ]
      @row += 1
    end
    book.write 'excelfile.xls'
    redirect_to :action => :index, company_id: session[:company]
  end

  def report_stock_pdf
    @date = Time.now
    @costcenter = CostCenter.find(session[:cost_center]).name
    @articleresult = get_report()
    prawnto inline: true, :prawn => { :page_size => 'A4', :page_layout => :portrait }

  end

  def get_report
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
      articleresult << [code,name,result]
    end
    return articleresult
  end
end