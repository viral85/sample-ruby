class Api::V1::OrganizationsController < Api::V1::Organizations::BaseController

  expose(:members) { build_members_scope(organization.members) }
  expose(:tool_summary) { build_tool_summary_scope  }

  def update
    organization.save!
    respond_with(organization)
  end

  private

  def build_members_scope(scope)
    scope = scope.preload(:member)

    # apply member_type filter
    scope = scope.where(member_type: params[:member_type]) if params[:member_type]

    # apply search filter
    scope = scope.search_by(params[:member_search_term]) if params[:member_search_term]

    # apply sort
    scope = scope.order('sort_terms')

    headers['totalItems'] = scope.count.to_s

    # apply paging
    scope.page(params[:accountMemberUsersPage] || params[:accountMemberOrganizationsPage] || DEFAULT_PAGE).per(params[:per_page] || DEFAULT_PER_PAGE)
  end

  def build_tool_summary_scope
    actable = organization.actable
    approved = OrganizationTool.where(:organization => actable, status: 'approved').count
    under_review = OrganizationTool.where(:organization => actable, status: 'under_review').count
    denied = OrganizationTool.where(:organization => actable, status: 'denied').count
    unknown = OrganizationTool.where(:organization => actable, status: 'unknown').count

    tools_count = OpenStruct.new
    tools_count.approved = approved
    tools_count.under_review = under_review
    tools_count.denied = denied
    tools_count.unknown = unknown
    tools_count.all = approved + under_review + denied + unknown
    tools_count
  end

end
