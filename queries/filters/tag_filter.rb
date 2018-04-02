class Filters::TagFilter < ExposeQuery::BaseQuery

  def apply(source_scope)
  	param_tag_ids = [params[:tag_id], params[:subject_id], params[:grade_id]].map { |value| value.blank? ? [] : value.split(',') }.flatten.compact.uniq
    tag_ids = param_tag_ids.map { |tag_id| Tag.by_ltee_paths(Tag.find(tag_id.to_i).ltree_path) }.flatten.uniq
    tag_ids.empty? ? source_scope : source_scope.where(id: Tagging.where(taggable_type: source_scope.model.to_s, tag_id: tag_ids).select(:taggable_id))
  end

end