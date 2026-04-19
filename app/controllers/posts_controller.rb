class PostsController < ApplicationController
  ALLOWED_DOWNLOADS = {
  "terms"   => "terms.pdf",
  "guide"   => "user_guide.pdf",
  "pricing" => "pricing.pdf"
}.freeze

  before_action :require_login, except: [:index, :show, :filter]
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def index
    @posts = Post.published.recent.includes(:user)
  end

  # INTENTIONAL SECURITY ISSUE: SQL Injection in filter
  def filter
    status = params[:status]

    @posts = Post.where(status: status)

    render :index
  end

  def show
    @comments = @post.comments.includes(:user)
    @post.increment!(:views_count)
  end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      redirect_to @post, notice: "Post created"
    else
      render :new
    end
  end

  def edit
    authorize_owner!(@post)
  end

  def update
    authorize_owner!(@post)

    if @post.update(post_params)
      redirect_to @post, notice: "Post updated"
    else
      render :edit
    end
  end

  def destroy
    authorize_owner!(@post)
    @post.destroy
    redirect_to posts_path, notice: "Post deleted"
  end

  def download
    key = params[:file]

    filename = ALLOWED_DOWNLOADS[key]
    raise ActiveRecord::RecordNotFound unless filename

    path = Rails.root.join("public", "downloads", filename)

    raise ActiveRecord::RecordNotFound unless File.exist?(path)

    send_file path, disposition: "attachment"
  end

  private

  def set_post
    @post = Post.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to posts_path, alert: "Post not found"
  end

  def post_params
    params.require(:post).permit(:title, :content, :status)
  end

  def authorize_owner!(resource)
    unless resource.user_id == current_user.id || current_user.role == "admin"
      redirect_to posts_path, alert: "Not authorized"
    end
  end
end
