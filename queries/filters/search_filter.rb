class Filters::SearchFilter < ExposeQuery::BaseQuery
	include Queries::SearchMixin

  def apply source_scope
		search(source_scope, params[:term])
  end
end