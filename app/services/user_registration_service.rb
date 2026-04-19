class UserRegistrationService
  attr_reader :user, :errors

  def initialize(params)
    @params = params
    @errors = []
  end

  def register
    validate_params || return

    @user = User.new(
      name: @params[:name],
      email: @params[:email],
      password: @params[:password],
      password_confirmation: @params[:password_confirmation]
    )

    unless @user.save
      @errors = @user.errors.full_messages
      return false
    end

    true
  end

  private

  def validate_params
    unless @params[:email].present?
      @errors << "Email is required"
      return false
    end

    unless @params[:password].present?
      @errors << "Password is required"
      return false
    end

    if @params[:password].length < 6
      @errors << "Password too short"
      return false
    end

    true
  end
end
