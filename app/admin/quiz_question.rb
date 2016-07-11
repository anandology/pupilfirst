ActiveAdmin.register QuizQuestion do
  menu parent: 'Start@College'
  permit_params :course_chapter_id, :question, answer_options_attributes: [:id, :value, :correct_answer, :_destroy]

  index do
    selectable_column
    column :question
    column :correct_answer do |question|
      question.correct_answer.value if question.correct_answer.present?
    end
    column :course_chapter_id
    actions
  end

  form do |f|
    # TODO: Reduce height of the text field below. 'input_html' seems to be malfunctioning
    f.inputs :question
    f.inputs :course_chapter
    f.inputs 'Answer Options' do
      f.has_many :answer_options, heading: false, allow_destroy: true, new_record: 'Add Option' do |o|
        o.input :value
        o.input :correct_answer
      end
    end
    f.actions
  end

  show do
    attributes_table do
      row :question
      row :course_chapter_id
      row :correct_answer do |question|
        question.correct_answer.value if question.correct_answer.present?
      end
      row :answer_options do |question|
        question.answer_options.pluck(:value).join(', ')
      end
    end
  end
end
