class FacultyController < ApplicationController
  # GET /faculty
  def index
    @skip_container = true
  end

  # POST /faculty/:id/connect
  def connect
    questions = params[:connect_request][:questions]
    faculty = Faculty.find(params[:id])
    connect_slot = faculty.connect_slots.find(params[:connect_request][:connect_slot])
    connect_request = connect_slot.build_connect_request(startup: current_user.startup, questions: questions)

    if connect_request.save
      flash[:success] = 'Connect Request has been submitted. You will receive an email once its confirmed.'
    else
      flash[:error] = 'Something went wrong while attempting to create connect request! :('
    end

    redirect_to faculty_index_path
  end

  # GET /faculty/:id/weekly_slots(token)
  def weekly_slots
    raise_not_found unless params[:token]
    @faculty = Faculty.find_by token: params[:token]
    raise_not_found unless @faculty

    @slot_list = create_slot_list_for @faculty
  end

  # POST /faculty/:id/save_weekly_slots(token)
  def save_weekly_slots
    raise_not_found unless params[:token]

    @faculty = Faculty.find_by token: params[:token]
    raise_not_found unless @faculty

    list_of_slots = JSON.parse(params[:list_of_slots])
    save_slots_in_list list_of_slots, @faculty

    flash.now[:success] = "Your slots have been saved succesfully!"
    redirect_to :back
  end

  private

  def save_slots_in_list(list, faculty)
    start_date = 7.days.from_now.beginning_of_week.to_date
    list.each do |slot|
      date = start_date + slot[0] - 1 # index of dates start at 1
      hour = slot[1].to_i
      minute = (((slot[1].to_f) - hour) * 60).to_s.delete('.')[0..1]

      connect_slot = faculty.connect_slots.find_or_initialize_by(
        slot_at: Time.parse("#{date} #{hour.to_s.rjust(2, '0')}:#{minute}:00 +0530")
      )
      connect_slot.save!
    end
  end

  def create_slot_list_for(faculty)
    slots = faculty.connect_slots.next_week
    list = slots.map do |slot|
      day = (slot.slot_at.to_date - 7.days.from_now.beginning_of_week.to_date).to_i + 1
      time = slot.slot_at.hour + slot.slot_at.min.to_f / 60
      "[#{day},#{time}]"
    end.join(',')
    "[#{list}]"
  end
end
