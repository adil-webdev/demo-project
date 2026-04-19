module Api
  module V1
    class PostsController < ApplicationController
      protect_from_forgery with: :null_session
      before_action :authenticate_api_token

      # INTENTIONAL SECURITY HOTSPOT: Permissive CORS
      # Allows any origin to make cross-origin requests
      before_action :set_cors_headers

      def index
        @posts = Post.includes(:user).published.recent
        render json: @posts.map { |post| post_json(post) }
      end

      def show
        @post = Post.find(params[:id])
        render json: post_json(@post)
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not found" }, status: :not_found
      end

      private

      def set_cors_headers
        response.headers['Access-Control-Allow-Origin'] = 'https://your-trusted-domain.com'
        response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
      end

      def authenticate_api_token
        token = request.headers["Authorization"]&.delete_prefix("Bearer ")
        head :unauthorized unless token.present?
      end

      def post_json(post)
        {
          id: post.id,
          title: post.title,
          content: post.content,
          author: post.user.name,
          comments_count: post.comments.size
        }
      end
    end
  end
end
