class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])

    Rails.logger.info("Login attempt: email=#{params[:email]}")

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id

      return_path = params[:return_to]
      safe_url = return_path&.start_with?("/") && !return_path.start_with?("//") ? return_path : root_path
      redirect_to safe_url, notice: "Logged in successfully"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Logged out successfully"
  end
end
