class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  layout :layout_by_resource
  protect_from_forgery with: :exception

  def layout_by_resource
    if devise_controller?
      false
    else
      'application'
    end
  end

  def record_activity(note)
    @watchdog = Watchdog.new
    @watchdog.user = current_user
    @watchdog.note = note
    @watchdog.browser = request.env['HTTP_USER_AGENT']
    @watchdog.ip_address = request.env['REMOTE_ADDR']
    @watchdog.save
  end

end
