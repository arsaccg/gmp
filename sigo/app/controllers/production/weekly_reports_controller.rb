class Production::WeeklyReportsController < ApplicationController
	def index
    @company = get_company_cost_center('company')
    @workingGroups = WorkingGroup.all
    @week = CostCenter.getWeek5(get_company_cost_center('cost_center'),Time.now.to_date.to_s)
    render layout: false
  end

  def get_report
    @cc = get_company_cost_center('cost_center')
  	@week3 = Array.new
    @cad = Array.new
    @cad4 = Array.new
    @result = params[:start_date].split(/,/)
    @article= params[:article]
    start_date = @result[1]
    end_date = @result[2]
    #Semanas que estan en la leyenda del gráfico
    if params[:article]=='0'
      working = WorkingGroup.where("cost_center_id ="+get_company_cost_center('cost_center').to_s)
      working.each do |wg|
        @cad4 << wg.id
      end
      @article = @cad4.join(',')
    end
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

    #Semanas que estan en la leyenda del gráfico-fin
    @costcenter = get_company_cost_center('cost_center')
    weeks = ActiveRecord::Base.connection.execute("
      SELECT wcc.id, wcc.end_date
      FROM  weeks_for_cost_center_" + @costcenter.to_s + " wcc
      WHERE  wcc.start_date <  '" + end_date.to_s + "' AND wcc.end_date >  '" + start_date.to_s + "'"
    )
    weeks.each do |id|
      if id[0].to_i<13
        @weeks = ActiveRecord::Base.connection.execute("
          SELECT wcc.name, wcc.start_date, wcc.end_date
          FROM  weeks_for_cost_center_" + @costcenter.to_s + " wcc
          WHERE  wcc.end_date <  '" + id[1].to_date.to_s + "'
        ")
      else
        first_id = id[0].to_i-9
        last_id = id[0].to_i + 1
        @weeks = ActiveRecord::Base.connection.execute("
          SELECT wcc.name, wcc.start_date, wcc.end_date
          FROM  weeks_for_cost_center_" + @costcenter.to_s + " wcc
          WHERE  wcc.id >=" + first_id.to_i.to_s + " AND wcc.id < " + last_id.to_s + "
        ")
      end
    end
    #Semanas que estan en la leyenda del gráfico-fin

    @weekhh =Array.new
    @weekcp =Array.new

    #revisa partes por semana
    @weeks.each do|inter|
      @weekhh << ActiveRecord::Base.connection.execute("
        SELECT ar.name
        FROM part_people pp, part_person_details ppd, workers w, worker_contracts wc, articles ar
        WHERE pp.cost_center_id = "+@cc.to_s+"
        AND pp.date_of_creation BETWEEN '" + inter[1].to_date.to_s + "' AND '" + inter[2].to_date.to_s + "'
        AND pp.blockweekly =0
        AND pp.working_group_id IN (" + @article.to_s + ")
        AND ppd.part_person_id = pp.id
        AND ppd.worker_id = w.id
        AND w.id = wc.worker_id
        AND wc.article_id = ar.id
        GROUP BY ar.name
      ")
    end
    @catehh = Array.new
    @catecp = Array.new

    @weekhh.each do |a|
      a.each do |b|
        @catehh << b[0]
        @catecp << b[0]
      end
    end
    @catehh = @catehh.uniq
    @catecp = @catecp.uniq
    
    @catwh = Array.new
    @catwp = Array.new
    @catehh.each do |cat|
      @weeks.each do |w|
        catwh = ActiveRecord::Base.connection.execute("
          SELECT SUM(ppd.total_hours)
          FROM part_people pp, part_person_details ppd, workers w, worker_contracts wc, articles ar
          WHERE pp.cost_center_id = "+@cc.to_s+"
          AND pp.date_of_creation BETWEEN '"+w[1].to_date.to_s+"' AND '"+w[2].to_date.to_s+"'
          AND pp.blockweekly =0
          AND pp.working_group_id IN (" + @article.to_s + ")
          AND ppd.part_person_id = pp.id
          AND ppd.worker_id = w.id
          AND w.id = wc.worker_id
          AND wc.article_id = ar.id
          AND ar.name = '"+cat.to_s+"'
          GROUP BY ar.name
        ")

        catwp = ActiveRecord::Base.connection.execute("
          SELECT SUM(1)
          FROM part_people pp, part_person_details ppd, workers w, worker_contracts wc, articles ar
          WHERE pp.cost_center_id = "+@cc.to_s+"
          AND pp.date_of_creation BETWEEN '"+w[1].to_date.to_s+"' AND '"+w[2].to_date.to_s+"'
          AND pp.blockweekly =0
          AND pp.working_group_id IN (" + @article.to_s + ")
          AND ppd.part_person_id = pp.id
          AND ppd.worker_id = w.id
          AND w.id = wc.worker_id
          AND wc.article_id = ar.id
          AND ar.name = '"+cat.to_s+"'
          GROUP BY pp.date_of_creation
        ")
        if catwh.count==1
          catwh.each do |c|
            @catwh << c[0].to_f
          end
        else
          @catwh<<0
        end
        @max = 0
        if catwp.count>0
          catwp.each do |c|
            if c[0].to_f > @max
              @max = c[0]
            end
          end
            @catwp <<  @max.to_f
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