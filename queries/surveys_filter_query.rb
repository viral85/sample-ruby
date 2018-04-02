class SurveysFilterQuery
  attr_reader :tool_ids
  delegate :account, :organization, :trial, :users_scope, :qualifying_values, to: :configuration

  def initialize(tool_ids)
    @tool_ids = tool_ids
  end

  def configuration
    @configuration ||= OpenStruct.new(account: nil,
                                      organization: nil,
                                      trial: nil,
                                      users_scope: User.where.not(verified_at: nil),
                                      qualifying_values: nil)
  end

  def configure
    yield configuration
  end

  def build_scope
    scope = base_surveys_scope.where!(filter_by_account_or_trial)
    (qualifying_values || []).each do |value|
      scope.where!(id: SurveyQuestionAnswer.where('? = ANY(values)', value).select(:survey_id))
    end
    scope
  end


  private

  def filter_by_account_or_trial
    if trial
       Survey.arel_table[:id].in(
          Survey.distinct.
                     joins(:trials).
                     where(tool_id: [tool_ids]).
                     where(trials: {id: trial.id}).
                     select(:id).arel)
    elsif account || organization

      # Get surveys for account trials
      trials_surveys =
        Survey.arel_table[:id].in(
          Survey.distinct.
                       joins(:trials).
                       where(tool_id: [tool_ids]).
                       where(trials: {account_id: account.id} ).
                       select(:id).arel) if account

      # Get surveys for account members
      organization_member_surveys =
        Survey.arel_table[:id].in(
          Survey.distinct.
                   where(tool_id: [tool_ids]).
                   where(user_id: (organization || account.accountable).get_descendents_by_type(User).select(:id)).
                   select(:id).arel)

      if trials_surveys && organization_member_surveys
        trials_surveys.or(organization_member_surveys)
      else
        organization_member_surveys
      end

    else # hide private surveys
      Survey.arel_table[:id].not_in(
          Survey.distinct.
                     joins(:trials).
                     where(tool_id: tool_ids).
                     where({trials: {is_private: true}}).
                     select(:id).arel)
    end
  end

  def base_surveys_scope
    Survey.distinct.joins(:user).
        where(tool_id: tool_ids).
        where(users: {id: users_scope.select(:id)})
  end

  def filtering_hash
    {}.tap do |result|
      result.merge!({trials: {account_id: account.id}}) if account
      result.merge!({trials: {id: trial.id}}) if trial
    end
  end

end
