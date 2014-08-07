class Logistics::ReportStocksController < ApplicationController
  def index
    article = Array.new
    result = 0.0
    name = ""
    @articleresult = Array.new
    sum = 0
    rest = 0
    stockinputdetail = StockInputDetail.all
    stockinputdetail.each do |si|
      article << si.article_id
    end
    article = article.uniq
    article.each do |art|
      name = Article.find(art).name
      sisum = StockInput.where("input = 1")
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
      @articleresult << [art,name,result]
    end
    #@articleresult = [article,name,result]
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
end