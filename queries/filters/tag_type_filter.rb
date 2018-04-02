class Filters::TagTypeFilter < ExposeQuery::BaseQuery

  def apply(source_scope)
    source_scope = params[:applicable_type] ? source_scope.by_applicable_type(params[:applicable_type]) : source_scope
    source_scope = params[:access_type] == "Public" ? source_scope.public_tags : source_scope
    params[:tag_type] ? source_scope.where(tag_type: params[:tag_type]) : source_scope.where.not(tag_type: %w(subject grade_level))
  end

end
