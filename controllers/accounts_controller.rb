class AccountsController < ApplicationController
  before_filter :authenticate_user!, except: [:public]
	load_and_authorize_resource except: :public

  expose!(:account, config: :verifiable) do |default|
    params[:public_id] ? Account.find_by!(public_profile: true, public_id: params[:public_id]) : default
  end

end
