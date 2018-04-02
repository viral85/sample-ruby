class OrganizationToolsQuery < BaseQuery

  def apply(scope)

    scope = scope.preload(:tool, :organization)
		scope = search(scope)
  	scope = sort(scope)
  	scope = paginate(scope, params[:organizationToolsPage], params[:per_page])

    controller.headers['totalItems'] = scope.except(:offset, :limit, :order).count if controller

  	scope
  end

  def search(scope)
    if params[:organization_id]
      organization = params[:organization_type].constantize_with_care([Group, School, SchoolDistrict, College, StateEducationAgency, Company]).find(params[:organization_id]) if params[:organization_type]
      organization = Organization.find(params[:organization_id]).actable if params[:organization_type].nil? || params[:organization_type] == Organization.to_s
    end

    scope = scope.reviewed if params[:reviewed]
    scope = scope.where(organization_id: organization.id) if organization
    scope = scope.where(organization_type: organization.class.name) if organization
    scope = scope.where(tool_id: params[:tool_id]) if params[:tool_id]
    scope = scope.where(status: params[:status]) if params[:status]
    scope = scope.search_by(params[:searchTerms] || params[:term]) if params[:searchTerms] || params[:term]
    scope
  end

end
