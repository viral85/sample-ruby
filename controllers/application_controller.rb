class ApplicationController < ActionController::Base
  include RenderNotFound
  include RenderAccessDenied
  include RenderException
  include LocalSubdomain

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # impersonate users
  impersonates :user

  helper CustomActionHelper

  before_filter :update_sanitized_params, if: :devise_controller?
  before_filter :register_custom_actions

  # rescue_from Exception, with: :render_exception 
  # rescue_from Exception, with: :render_exception unless Rails.env.development? && !request.format.symbol == :html
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from CanCan::AccessDenied, with: :render_access_denied

  DEFAULT_PAGE = 0
  DEFAULT_PER_PAGE = 1000

  decent_configuration(:strong) do
    strategy DecentExposure::StrongParametersStrategy
  end

  def update_sanitized_params
    devise_parameter_sanitizer.for(:sign_up).
        push(:first_name, :last_name, :role_ids,
             taggings_attributes: [:tag_id],
             memberships_attributes: [:organization_type, :organization_id])
  end

  def after_sign_in_path_for(resource)
    stored_location = stored_location_for(resource)
    (stored_location.nil? || stored_location == root_path) ? root_path_for_user : stored_location
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  # handle any custom action code in the query strings
  def register_custom_actions
    session[:custom_actions] ||= []
    session[:custom_actions] << params[:cact] unless params[:cact].blank? || session[:custom_actions].include?(params[:cact])
    CustomActionHelper.process_custom_actions(current_user, session[:custom_actions])
  end

  def register_event(event_type, eventable)
    Event::Register.instance.save({
                                      :event_type => event_type,
                                      :eventable => eventable,
                                      :user => current_user
                                  })
  end

  # def authorize_system_administrator!
  #   handle_unauthorized_access unless current_user.has_role? :system_administrator or true_user.has_role?(:system_administrator)
  # end

  def authorize_user_as_member_of_paid_account!
    railse CanCan::AccessDenied if current_user.nil? || (!current_user.has_role?(:system_administrator) && !current_user.member_of_paid_account?) 
    # handle_unauthorized_access if current_user.nil? || (!current_user.has_role?(:system_administrator) && !current_user.member_of_paid_account?)
  end

  def current_organization
    @current_organization ||= Organization.where(subdomain: env['current_organization_subdomain']).first if env['current_organization_subdomain']
  end

  private

  # def handle_unauthorized_access
  #   if request.content_type === "application/json"
  #     render :json => {notice: 'You are not authorized to visit this page'}, :status => 403
  #   else
  #     flash[:notice] = "You are not authorized to visit this page."
  #     begin
  #       redirect_to :back
  #     rescue ActionController::RedirectBackError
  #       redirect_to root_path
  #     end
  #   end
  # end

  def root_path_for_user
    if current_user && current_user.primary_organization
      if current_user.primary_organization.actable.is_a? Company
        path = organization_path(current_user.primary_organization)
      else
        account = Account.where(accountable: current_user.primary_organization.actable).first
        path = account_path(account) if account
      end
    end

    path || root_path
  end

end
