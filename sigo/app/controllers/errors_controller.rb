class ErrorsController < ApplicationController
  def error_404
  	render :status => 404, layout: 'empty'
  end

  def error_500
  	render :status => 500, layout: 'empty'
  end
end
