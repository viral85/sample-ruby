class ProfilesController < ApplicationController
  include PdfExport

  acts_as_token_authentication_handler_for User, except: [:public, :ed]
  before_filter :authenticate_user!, except: [:public, :ed]

  respond_to :html, :pdf

  expose(:profile) do
    user = if !params[:id].blank?
      User.find(params[:id])
    elsif !params[:public_id].blank?
      User.find_by(public_id: params[:public_id])
    else
      current_user
    end
    ProfilePresenter.new(user)
  end

  expose!(:account) {
    params[:account_id] ? Account.find(params[:account_id]) : nil
  }

end
