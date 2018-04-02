class TopToolsQuery

  LIMIT = 10

  def top
    scope = Tool.where(published: true)
    # surveys with question answered diferents to qualifying question
    scope = scope.joins(:survey_question_answers).where(:survey_question_answers => { i_cant_answer: false, values: nil })
    # group by tool and its average and limited by 10
    scope = scope.group('tools.id').order('average_value DESC').limit(LIMIT).average(:value)
    # find top tools by id
    Tool.where(:id => scope.map(&:first))
  end

end
