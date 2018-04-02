class Filters::DataTablesQuery < ExposeQuery::BaseQuery

  def apply source_scope
    source_scope = sort(source_scope)
    source_scope = search(source_scope)
    paginate(source_scope)
  end


  private

  def paginate scope
    scope = scope.page(params['iDisplayStart'].to_i / params['iDisplayLength'].to_i + 1).per(params['iDisplayLength'].to_i) if params['iDisplayStart'] && params['iDisplayLength']
    scope
  end

  def sort scope
    params['iSortCol_0'] ? scope.order(sorting_conditions(scope)) : scope # scope.order("#{scope.table_name}.id")
  end

  def sorting_conditions(scope)
    if params["mDataProp_#{params['iSortCol_0']}"]
      sort_column = params["mDataProp_#{params['iSortCol_0']}"]
      ((['key', 'name'].include?(sort_column)) ? "lower(#{scope.table_name}.#{sort_column})" : "#{scope.table_name}.#{sort_column}") + ' ' + params['sSortDir_0']
    end
  end

  def search scope
    unless params['sSearch'].blank?
      search_parameter_array = params['sSearch'].downcase.split(' ').map { |word| "%#{word}%" }.uniq
      scope = scope.where("#{scope.table_name}.search_terms like all (array[?])", search_parameter_array)
    end

    scope = scope.where(account_id: params[:account_id]) unless params[:account_id].blank?
    scope = scope.where(company_id: params[:company_id]) unless params[:company_id].blank?

    scope
  end

end