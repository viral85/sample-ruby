class Filters::AdminSurveyFilter < ExposeQuery::BaseQuery

  def apply(source_scope)
    params[:tool_id] ? source_scope.where(tool_id: params[:tool_id]) : source_scope
  end

end