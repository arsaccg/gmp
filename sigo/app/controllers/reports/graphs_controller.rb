class Reports::GraphsController < ApplicationController
  def do_graph
    canvas = params[:canvas].split("-")
    @canvas_x = canvas[0]
    @canvas_y = canvas[1]
    @canvas_width = canvas[2]
    @canvas_height = canvas[3]
    
    @graph_type = canvas[4]
    
    @div_destination = canvas[5]
    
    graph = params[:graph].split("-")
    
    p canvas
    p graph
    
    @graph_x = graph[0]
    @graph_y = graph[1]
    @graph_width = graph[2]
    @graph_height = graph[3]
    
    @graph_type = graph[4]
    
    @graph_data = graph[5]
    
    @graph_options = graph[6]
    
    case @graph_type
      when 1 #bar
        
      when 2 #dot
        
      when 3 #line
        
      when 4 #pie
        
    end
    
    render :partial => 'do_graph', layout: false
    
  end
end