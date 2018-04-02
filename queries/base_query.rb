class BaseQuery < ExposeQuery::BaseQuery

	DEFAULT_PAGE = 0
	DEFAULT_PER_PAGE = 20

	def paginate(scope, page, per_page)
    scope = scope.page(page || DEFAULT_PAGE).per(per_page || DEFAULT_PER_PAGE) if (page || per_page || !scope.respond_to?(:total_count))
    scope
	end

	def sort(scope, direction = :asc)
		scope.order(sort_terms: direction)
	end

end
