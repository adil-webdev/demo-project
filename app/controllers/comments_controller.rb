class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_post
  before_action :set_comment, only: [:destroy]

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user
    @comment.ip_address = request.remote_ip

    if @comment.save
      redirect_to @post, notice: "Comment added"
    else
      redirect_to @post, alert: "Comment failed"
    end
  end

  def destroy
    unless @comment.user_id == current_user.id || current_user.role == "admin"
      redirect_to @post, alert: "Not authorized" and return
    end

    @comment.destroy
    redirect_to @post, notice: "Comment deleted"
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
