class ToolsQuery < BaseQuery

  def apply(scope)

    scope = scope.preload(:logo, :subjects)
		scope = search(scope)
  	scope = sort(scope)
  	scope = paginate(scope, params[:toolsPage], params[:per_page])

    controller.headers['totalItems'] = scope.except(:offset, :limit, :order).count if controller

  	scope
  end

  def search(scope)
  	scope = scope.where(published: true) if params[:action] == 'index' && !params[:company_id]
  	scope = scope.where(company_id: params[:company_id]) if params[:company_id]
  	scope
  end

  def sort(scope)
  	scope = scope.order('(case when rating = 0 then 0 else 1 end) desc') if params[:sort] == 'rated_alphabetical'
    scope.order('lower(name)')
  end

  def filter_by_subject(scope)
    params[:subject_id] ? scope.joins(:tags).where(tags: {id: params[:subject_id],tag_type: 'subject' }) : scope
  end

end
