class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create if Rails.env.development? # omniauth developer strategy only
  skip_after_action :verify_authorized # none of these methods require authentication

  def new
  end

  def create
    auth = request.env["omniauth.auth"]
    user = User.find_by_forum_member_id!(auth[:uid])

    reset_session
    session[:user_id] = user.id
    redirect_to request.env["omniauth.origin"] || root_url, notice: "Signed in!"
  end

  def destroy
    reset_session
    forums_base_url = Rails.configuration.endpoints[:discourse][:base_url][:external]
    redirect_to root_url, notice: "Signed out!"
    # redirect_to "#{forums_base_url}/logout"
  end

  def failure
    redirect_to root_url, alert: "Authentication error"
  end
end
