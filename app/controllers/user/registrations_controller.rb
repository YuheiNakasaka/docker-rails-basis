# frozen_string_literal: true

class User::RegistrationsController < Devise::ConfirmationsController
  def show
    super do
      return render :show
    end
  end
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    registered = User::DatabaseAuthentication.exists?(email: params[:registration][:email])
    if registered
      flash[:error] = 'Given email address is already registered.'
      return render :new
    end

    user_registration = User::Registration.find_or_initialize_by(unconfirmed_email: params[:registration][:email])
    if user_registration.save
      super do
        flash[:notice] = 'Sending an email confirmation instruction'
        return render :create
      end
    else
      respond_with(user_registration)
    end
  end

  def finish
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    ActiveRecord::Base.transaction do
      @user = User.new(nickname: params[:nickname])
      @user_database_authentication = User::DatabaseAuthentication.new(user: @user, email: params[:email],
                                                                       password: params[:password], password_confirmation: params[:password_confirmation])
      @user.save!
      @user_database_authentication.save!
      resource.destroy!
    end

    sign_in(:user, @user)
    sign_in(:database_authentication, @user_database_authentication)

    redirect_to root_path
  rescue StandardError
    render :show
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
