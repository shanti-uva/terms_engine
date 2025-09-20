module TermsEngine
  module UsersControllerOverrides
    private
    
    def user_params
      params.require(:authenticated_system_user).permit(:login, :email, :password, :password_confirmation, :identity_url, :access_token)
    end
  end
end
