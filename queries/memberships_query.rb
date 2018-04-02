class MembershipsQuery < BaseQuery

	DEFAULT_PAGE = 0
	DEFAULT_PER_PAGE = 20

  def apply scope
  	scope = search(scope)
  	scope = sort(scope)
  	scope = paginate(scope, params[:organizationsMembershipsPage] || params[:usersMembershipsPage], params[:per_page])

    controller.headers['totalItems'] = scope.except(:offset, :limit, :order).count if controller

  	scope
  end

  private

  def search scope

  	organization_klass = (params[:organization_type]) ? params[:organization_type].constantize_with_care(Organization.types + [Organization]) : Organization
  	organization = organization_klass.find(params[:organization_id]) if params[:organization_id]
  	organization = organization.acting_as if organization && !organization.is_a?(Organization)
  	member_types = (params[:member_type] == 'Organization') ? Organization.types : [params[:member_type]] if params[:member_type]

  	scope = scope.where(organization_id: organization.actable_id) if organization
  	scope = scope.where(organization_type: organization.actable_type) if organization
  	scope = scope.where(member_id: params[:member_id]) if params[:member_id]
  	scope = scope.where(member_type: member_types) if member_types
  	scope = scope.where("lower(search_terms) like '%#{params[:member_search_term].downcase}%'") if params[:member_search_term]
  	scope
  end


end