class ApplicationController < ActionController::Base
 
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?

  helper_method :sys_admin?, :admin?, :manager

 
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:dni, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:dni, :email, :password) }
  end

  #http://railscasts.com/episodes/20-restricting-access
  def authorize_admin
   #  unless admin? || sys_admin?
   # 	  redirect_to management_projects_path #management_dashboard_path+"?project=1"  #
  	# 	flash[:error] = "Unauthorized Access"
  	# # 	false
  	# end
    true
  end

  def authorize_manager
    #unless manager? || sys_admin?
    #  redirect_to management_projects_path #management_dashboard_path+"?project=1"  #
    #  flash[:error] = "Unauthorized Access"
    #   false
    #end
    true
  end

  def sys_admin?
    current_manager.kind == '1'
  end

  def admin?
  	current_manager.kind == '2'
  end

  def manager?
  	current_manager.kind == '3'
  end

end
