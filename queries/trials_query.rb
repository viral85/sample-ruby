class TrialsQuery < ::Filters::SearchFilter

  def apply source_scope

    scope = source_scope.preload(tools:[:logo] ).includes(:survey_questions).
        page(params[:trialsPage])

    scope = source_scope.where(:archived => params[:archived]) unless params[:archived].blank?

    controller.headers['totalItems'] = scope.count.to_s
    scope.select('trials.*').
              select(surveys_count).
              select(answers).
              select(products).order(:created_at)
  end

  private

  def surveys_count
    Arel.sql('(select count(distinct surveys.user_id) from surveys_trials join surveys on surveys.id = surveys_trials.survey_id
                         where surveys_trials.trial_id = trials.id)').as('surveys_count')
  end

  def answers
    Arel.sql('(select count(surveys.id)
                      from surveys_trials
               join surveys on surveys.id = surveys_trials.survey_id
                         where surveys_trials.trial_id = trials.id)').as('answers')
  end

  def products
    Arel.sql('(select count(distinct surveys.tool_id)
                      from surveys_trials
               join surveys on surveys.id = surveys_trials.survey_id
                         where surveys_trials.trial_id = trials.id)').as('products')
  end


end
