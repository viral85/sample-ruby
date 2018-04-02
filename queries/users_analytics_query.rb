class UsersAnalyticsQuery
  
  attr_reader :params
  attr_reader :scope
  
  def initialize(params, verified_users_only = false)
    @params = params.symbolize_keys
    @scope = verified_users_only ? User.where.not(verified_at: nil) : User.all
    @params.keys.each do |param_key|
      send(params_mapping[param_key]) if params_mapping[param_key]
    end

    Rails.logger.info("QUERY - #{scope.to_sql}")
  end
  
  private

  def filter_by_district_type
    
  end

  def filter_by_reduced_lunch
    unless params[:by_students_lunch].blank?
      joins_schools
      from, to = params[:by_students_lunch].split('/')
      scope.where!(School.arel_table[:total_students].gt(0)).
          where!('((schools.students_eligibile_for_free_lunch + schools.students_eligibile_for_reduced_price_lunch ) / schools.total_students::float) * 100  BETWEEN ? AND ?', from, to )
    end
  end

  def filter_by_school_size
    unless params[:by_school_size].blank?
      joins_schools
      from, to = params[:by_school_size].split('/')
      scope.where!('schools.total_students BETWEEN ? AND ?', from, to )
    end
  end

  def filter_by_school_type
    joins_schools
    case params[:by_school_type].to_sym
      when :public
        scope.where!(schools: { is_public_school: true })
      when :private
        scope.where!(schools: { is_public_school: false })
      when :public_charter
        scope.where!(schools: { is_public_school: true, is_charter_school: true})
      when :home
        scope.where!(schools: { is_home_school: true})
    end
  end

  def filter_by_subject
    filter_by_tag(params[:by_subject_id], 'subject')
  end

  def filter_by_school_level
    filter_by_tag(params[:by_school_level_id], 'grade_level')
  end

  def filter_by_user_verification
    case params[:by_verification].to_sym
      when :verified
        scope.where!.not(verified_at: nil)
    end
  end

  def joins_schools
    return if @school_are_joined
    scope.joins!(:memberships).
        joins!("INNER JOIN schools ON schools.id = memberships.organization_id AND memberships.organization_type = 'School'")
    @school_are_joined = true
  end

  def filter_by_tag(param, tag_type)
    tag = Tag.find(param)
    scope.joins!(:tags).where!(
        Tag.arel_table[:ltree_path].is_descendant_any([tag.ltree_path])
    ).where!(tags: {tag_type: tag_type})
  end

  def params_mapping
    {
        by_school_size: :filter_by_school_size,
        by_verification: :filter_by_user_verification,
        by_school_type: :filter_by_school_type,
        by_subject_id: :filter_by_subject,
        by_school_level_id: :filter_by_school_level,
        by_students_lunch: :filter_by_reduced_lunch
    }
  end

end