class LinkPeriod < ActiveRecord::Base
  belongs_to :cost_center

  # LinkPeriod.LoadTimeLine(1, Date.parse("31-01-2000"), Date.parse("13-02-2000"))
  def self.LoadTimeLine(p_cost_center, p_from, p_to)
    @from = p_from
    @to = p_to
    @dates = LinkTime.from(@from).to(@to)
    @year = @from.strftime("%Y").to_i
    @week = 1
    @i = 0
    @d = 1
    @m = 1
    @mt = 1
    @iDate = @from
    @iDateYearNext = @from.years_since(1)
    @iDateMonthNext = @from.months_since(1)

    # Clean Periodo by Cost Center
    LinkPeriod.delete_all({cost_center_id: p_cost_center})
    # Load Link Period
    @dates.each do |x|
      @i +=1
      # Year changed
      if @iDate == @iDateYearNext
        @year += 1
        @m = 1
        @mt += 1
        @d = 1
        @week = 1
        @i = 1
        @iDateYearNext += 1.year
        @iDateMonthNext = @from.months_since(@mt)
      else
        # Month changed
        if @iDate == @iDateMonthNext
          @m += 1
          @mt += 1
          @d = 1
          @iDateMonthNext = @from.months_since(@mt)
          logger.info @iDateMonthNext
        end
      end
      LinkPeriod.create({:cost_center_id => p_cost_center, :date => x.date, :year => @year, :month => @m, :week => @week, :day => @d })
      @d +=1
      @iDate +=1
      # Week changed
      if @i % 7 == 0
        @week += 1
      end
    end
  end
end
