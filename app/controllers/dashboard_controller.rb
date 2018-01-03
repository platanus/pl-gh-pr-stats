class DashboardController < ApplicationController
  def index
    if authenticated?
      @corrmat = CorrelationMatrix.new(GithubUser.where(tracked: true))
      @corrmat.fill_matrix
      @auth_login = session[:data][0][1]
    else
      redirect_to '/oauth'
    end
  end

  def oauth_request
    session[:access_token] = nil
  end

  def get_user_data
    client = OctokitClient.client(session[:access_token])
    client.user
  end

  def authenticated?
    session[:access_token]
  end

  def authenticate!
    redirect_to OctokitClient.auth_client_url
  end

  def callback
    session_code = request.query_parameters['code']
    result = OctokitClient.exchange_code_for_token(session_code)
    session[:access_token] = result[:access_token]
    session[:data] = get_user_data
    redirect_to '/'
  end
end
