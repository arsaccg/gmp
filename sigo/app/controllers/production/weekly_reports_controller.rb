class Production::WeeklyReportsController < ApplicationController
	def index
    @company = get_company_cost_center('company')
    @workingGroups = WorkingGroup.all
    @week = CostCenter.getWeek5(get_company_cost_center('cost_center'),Time.now.to_date.to_s)
    render layout: false
  end

  def get_report
  	@week3 = Array.new
    @cad = Array.new
    @cad4 = Array.new
    @result = params[:start_date].split(/,/)
    @article= params[:article]
    puts @article.inspect
    if params[:article]=='0'
      working = WorkingGroup.all
      working.each do |wg|
        @cad4 << wg.id
      end
      @article = @cad4.join(',')
    end
    start_date = @result[1]
    end_date = @result[2]
    @week = CostCenter.getWeek(get_company_cost_center('cost_center'),Time.now.to_date.to_s)
    if @week.count>=10
      @week3 = CostCenter.getWeek3(get_company_cost_center('cost_center'),end_date.to_s,10)
      @week3.each do |week3|
        @cad << week3[1] + ' ' + week3[2].strftime("%d/%m") + '-' + week3[3].strftime("%d/%m")
      end
      @cad.reverse!
    else
      @week2 = CostCenter.getWeek2(get_company_cost_center('cost_center'),Time.now.to_date.to_s,10-@week.count)
      @week.each do |week|
        @week3 << week
      end
      @week2.each do |week|
        @week3 << week
      end
      @week3.each do |week3|
        @cad << week3[1] + ' ' + week3[2].strftime("%d/%m") + '-' + week3[3].strftime("%d/%m")
      end
    end
    @costcenter = get_company_cost_center('cost_center')
    weeks = ActiveRecord::Base.connection.execute("
      SELECT wcc.id
      FROM  weeks_for_cost_center_"+@costcenter+" wcc
      WHERE  wcc.start_date <  '"+end_date.to_s+"' AND wcc.end_date >  '"+start_date.to_s+"'"
    )
    weeks.each do |id|
      if id[0].to_i<13
        @weeks = ActiveRecord::Base.connection.execute("
          SELECT wcc.name, wcc.start_date, wcc.end_date
          FROM  weeks_for_cost_center_"+@costcenter+" wcc
          WHERE  wcc.end_date <  '"+id[2].to_date.to_s+"'
        ")
      else
        first_id = id[0].to_i-9
        last_id = id[0].to_i + 1
        @weeks = ActiveRecord::Base.connection.execute("
          SELECT wcc.name, wcc.start_date, wcc.end_date
          FROM  weeks_for_cost_center_"+@costcenter+" wcc
          WHERE  wcc.id >="+first_id.to_i.to_s+" AND wcc.id < "+last_id.to_s+"
        ")
      end
    end
    @weekhh =Array.new
    @weekcp =Array.new
    @weeks.each do|inter|
      @weekhh << ActiveRecord::Base.connection.execute("
        SELECT c.name, ppd.total_hours AS total_h, pp.date_of_creation
        FROM part_people pp, part_person_details ppd, articles a, workers w, categories c
        WHERE pp.date_of_creation BETWEEN '"+inter[1].to_date.to_s+"' AND '"+inter[2].to_date.to_s+"'
        AND pp.blockweekly=0
        AND ppd.part_person_id=pp.id
        AND ppd.worker_id=w.id
        AND w.article_id=a.id
        AND a.category_id = c.id
        AND pp.working_group_id IN("+@article.to_s+")
        GROUP BY c.name
      ")

      @weekcp << ActiveRecord::Base.connection.execute("
        SELECT c.name AS C_name, Sum(1) AS Cantidad_personas, pp.date_of_creation
        FROM part_people pp, part_person_details ppd, articles a, workers w, categories c
        WHERE pp.date_of_creation BETWEEN '"+inter[1].to_date.to_s+"' AND '"+ inter[2].to_date.to_s+"'
        AND pp.blockweekly=0
        AND ppd.part_person_id=pp.id
        AND ppd.worker_id=w.id
        AND w.article_id=a.id
        AND a.category_id = c.id
        AND pp.working_group_id IN("+@article.to_s+")
        GROUP BY c.name
      ")
    end
    @catehh = Array.new
    @catecp = Array.new

    @weekhh.each do |a|
      a.each do |b|
        @catehh << b[0]
      end
    end
    @catehh = @catehh.uniq

    @weekcp.each do |a|
      a.each do |b|
        @catecp << b[0]
      end
    end
    @catecp = @catecp.uniq
    
    @catwh = Array.new
    @catwp = Array.new
    @catehh.each do |cat|
      @weeks.each do |w|
        catwh = ActiveRecord::Base.connection.execute("
          SELECT SUM(ppd.total_hours)
          FROM part_people pp, part_person_details ppd, articles a, workers w, categories c
          WHERE pp.date_of_creation BETWEEN '"+w[1].to_date.to_s+"' AND '"+w[2].to_date.to_s+"'
          AND pp.blockweekly=0
          AND ppd.part_person_id = pp.id
          AND ppd.worker_id = w.id
          AND w.article_id = a.id
          AND a.category_id = c.id
          AND c.name LIKE '"+cat.to_s+"'
          AND pp.working_group_id IN("+@article.to_s+")
          GROUP BY c.name
        ")
        if catwh.count==1
          catwh.each do |c|
            @catwh << c[0].to_f
          end
        else
          @catwh<<0
        end
      end
    end

    @catecp.each do |cat|
      @weeks.each do |w|
        catwp = ActiveRecord::Base.connection.execute("
          SELECT SUM(1)
          FROM part_people pp, part_person_details ppd, articles a, workers w, categories c
          WHERE pp.date_of_creation BETWEEN '"+w[1].to_date.to_s+"' AND '"+w[2].to_date.to_s+"'
          AND pp.blockweekly=0
          AND ppd.part_person_id = pp.id
          AND ppd.worker_id = w.id
          AND w.article_id = a.id
          AND a.category_id = c.id
          AND c.name LIKE '"+cat.to_s+"'
          AND pp.working_group_id IN("+@article.to_s+")
          GROUP BY c.name
        ")
        if catwp.count==1
          catwp.each do |c|
            @catwp << c[0].to_f
          end
        else
          @catwp<<0
        end
      end
    end
    # GLOBAL Variables
    type = 'column'
    type2 = 'spline'

    @i=0
    @serieh = Array.new
    @seriep = Array.new

    @serie1 = Array.new
    @spline1 = Array.new
    @serie2 = Array.new
    @spline2 = Array.new

    @catehh.each do |c|
      f=@i+9
      @parteh = @catwh[@i.to_i..f.to_i]
      @serie1 << {
                  name: c,
                  data: @parteh
                }
      @i+=10
    end
    @i2=0
    @catecp.each do |c|
      f=@i2+9
      @partep = @catwp[@i2.to_i..f.to_i]
      @serie2 << {
                  name: c,
                  data: @partep
                }
      @i2+=10
    end
    @serieh = @serie1
    @seriep = @serie2
    render(partial: 'report_table', :layout => false)
  end
end