class UsersController < ApplicationController
  before_action :require_login, except: [:new, :create]
  before_action :set_user, only: [:show, :edit, :update, :profile]

  def index
    @users = User.all
  end


  def show
    # Show user profile with recent activity
    @recent_posts = @user.posts.order(created_at: :desc).limit(5)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Account created"
    else
      render :new
    end
  end

  def profile
    @post_count = @user.posts.count
    @comment_count = @user.comments.count
    @recent_posts = @user.posts.order(created_at: :desc).limit(5)
    @recent_comments = @user.comments.order(created_at: :desc).limit(5)

    # INTENTIONAL SECURITY ISSUE: Sensitive data exposure
    # SSN should never be exposed in a response
    @ssn = @user.ssn
  end

  def edit
    authorize_owner!(@user)
  end

  def update
    authorize_owner!(@user)

    if @user.update(user_params)
      redirect_to @user, notice: "User updated"
    else
      render :edit
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to users_path, alert: "User not found"
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, )
  end

  def authorize_owner!(resource)
    unless resource.id == current_user.id || current_user.role == "admin"
      redirect_to root_path, alert: "Not authorized"
    end
  end
end
