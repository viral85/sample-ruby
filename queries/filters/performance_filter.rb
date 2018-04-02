class Filters::PerformanceFilter < ExposeQuery::BaseQuery

  def apply(source_scope)
    params[:high_performance_growth_schools] ? 
    	source_scope.where(id: Survey.where(user_id: School.joins(:members).where(performance_growth_position: 'top', memberships: {member_type: 'User'}).select(:member_id)).select(:tool_id)) :
    	source_scope
  end

end