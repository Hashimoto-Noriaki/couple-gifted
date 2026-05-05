class Auth::RegistrationsController < DeviseTokenAuth::RegistrationsController
  def sign_up_params
    params.permit(:email, :password, :password_confirmation, :nickname, :gender, :relationship_status)
  end
end
