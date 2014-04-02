class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  layout :layout_by_resource
  helper_method :current_company
  protect_from_forgery with: :exception

  def layout_by_resource
    if devise_controller?
      false
    else
      'application'
    end
  end

  private
    # Make global variable company
    def current_company
      @company = 0
    end
end
