ActiveAdmin.register ConnectRequest do
  permit_params :connect_slot_id, :startup_id, :questions

  menu parent: 'Faculty'

  scope :all, default: true
  scope :confirmed
  scope :requested
  scope :cancelled

  filter :connect_slot_faculty_user_name, as: :string, label: 'Name of Faculty'
  filter :startup_name, as: :string
  filter :questions
  filter :status, as: :select, collection: -> { ConnectRequest.valid_statuses }
  filter :meeting_link
  filter :created_at
  filter :confirmed_at
  filter :rating_for_faculty
  filter :rating_for_team

  controller do
    def scoped_collection
      super.includes :connect_slot
    end
  end

  action_item :record_feedback, only: :show do
    link_to 'Record Feedback', new_admin_startup_feedback_path(startup_feedback: { startup_id: connect_request.startup.id })
  end

  index do
    selectable_column

    column :connect_slot
    column :startup, label: 'Product'
    column :status
    column :slot_date, sortable: 'connect_slots.slot_at' do |connect_request|
      connect_request.connect_slot.slot_at.in_time_zone('Asia/Calcutta').strftime('%b %-d, %-I:%M %p')
    end

    column :rating_for_faculty do |connect_request|
      if connect_request.rating_for_faculty.present?
        connect_request.rating_for_faculty.times do
          i class: 'fa fa-star'
        end
      end
    end

    column :rating_for_team do |connect_request|
      if connect_request.rating_for_team.present?
        connect_request.rating_for_team.times do
          i class: 'fa fa-star'
        end
      end
    end
  end

  show do
    attributes_table do
      row :id
      row :connect_slot
      row :startup, label: 'Product'

      row :questions do |connect_request|
        simple_format connect_request.questions
      end

      row :status do |connect_request|
        span class: 'connect-request-status' do
          connect_request.status
        end
      end

      row :meeting_link

      row :rating_for_faculty do |connect_request|
        if connect_request.rating_for_faculty.present?
          connect_request.rating_for_faculty.times do
            i class: 'fa fa-star'
          end
        end
      end

      row :comment_for_faculty

      row :rating_for_team do |connect_request|
        if connect_request.rating_for_team.present?
          connect_request.rating_for_team.times do
            i class: 'fa fa-star'
          end
        end
      end
      row :comment_for_team
      row :confirmed_at
      row :feedback_mails_sent_at
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs 'Connect Request Details' do
      f.input :connect_slot,
        collection: (resource.persisted? ? ConnectSlot.available.or(ConnectSlot.includes(:connect_request).where(id: resource.connect_slot.id)) : ConnectSlot.available).includes(:faculty),
        required: true
      f.input :startup, label: 'Product', collection: Startup.order(:name), required: true
      f.input :questions
    end

    f.actions
  end

  csv do
    column :startup do |connect_request|
      connect_request.startup&.name
    end
    column :faculty_name do |connect_request|
      connect_request.faculty&.name
    end
    column :questions
    column :status
    column :meeting_link
    column :created_at
    column :updated_at
    column :confirmed_at
    column :feedback_mails_sent_at
    column :rating_for_faculty
    column :rating_for_team
    column :connect_slot
  end
end
