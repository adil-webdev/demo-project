class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user, :logged_in?

  # SECURITY ISSUE: Session management without proper security
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def logged_in?
    !current_user.nil?
  end

  # SECURITY ISSUE: Weak authentication check
  def require_login
    unless logged_in?
      redirect_to root_path, alert: "Please log in"
    end
  end

  # SECURITY HOTSPOT: Authorization check without proper implementation
  def require_admin
    unless current_user && current_user.role == 'admin'
      redirect_to root_path, alert: "Admin access required"
    end
  end
end
