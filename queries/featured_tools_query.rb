class FeaturedToolsQuery

  def initialize(user = nil)
    @user = user
  end

  def tools
    @tools ||= [].tap do |featured|
      if @user
        scope = base_scope.joins(:trials).where(trials: { id: @user.eligible_trials.select(:id) })
        featured << scope.where.not(id: @user.surveys.pluck(:tool_id)).limit(5)
        featured << base_scope.reorder(rating: :desc).limit(5 - featured.flatten.count) if featured.flatten.count < 5
      else
        featured << base_scope.reorder(rating: :desc).limit(5)
      end

      featured.flatten!
    end
  end

  def base_scope
    scope = Tool.where(published: true)
    scope = scope.where.not(id: @user.surveys.pluck(:tool_id)).distinct.limit(5) if @user
    scope
  end

end