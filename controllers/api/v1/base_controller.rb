class Api::V1::BaseController < ApplicationController
  # load_and_authorize_resource

  # before_action :auth_check
  skip_before_action :verify_authenticity_token
  
  respond_to :json

  protected

  def auth_check
    render_not_authorized unless authentication_token == params[:token]
  end

  def render_not_authorized
    head(403)
  end
end
