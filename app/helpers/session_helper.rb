module SessionHelper
  def find_question(recent_questions, id)
    recent_questions.each do |question|
      if question.questionId == id
        return question
      end
    end
  end
end
