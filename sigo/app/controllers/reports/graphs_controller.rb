class Reports::GraphsController < ApplicationController
  def do_graph
    canvas = params[:canvas].split(",")
    @canvas_x = canvas[0]
    @canvas_y = canvas[1]
    @canvas_width = canvas[2]
    @canvas_height = canvas[3]
    
    @graph_type = canvas[4]
    
    @div_destination = canvas[5]
    
    graph = params[:graph].split(",")
    
    
    @graph_x = canvas[0]
    @graph_y = canvas[1]
    @graph_width = canvas[2]
    @graph_height = canvas[3]
    
    @graph_data = canvas[4]
    
    case canvas_type
      when 1 #bar
        
      when 2 #dot
        
      when 3 #line
        
      when 4 #pie
        
    end
    
    render :partial => 'do_graph', layout: false
    
  end
end