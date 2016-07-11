class QuizQuestion < ActiveRecord::Base
  belongs_to :course_chapter
  has_many :answer_options
  accepts_nested_attributes_for :answer_options, allow_destroy: true
  has_one :correct_answer, -> { where(correct_answer: true) }, class_name: 'AnswerOption', foreign_key: 'quiz_question_id'
end
