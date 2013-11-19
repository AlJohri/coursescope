class Classtime < ActiveRecord::Base
  belongs_to :course
  belongs_to :classroom

  serialize :start_time, Tod::TimeOfDay
  serialize :end_time, Tod::TimeOfDay

  validates :course_id, presence: true
  validates :classroom_id, presence: true
  # validates :start_time
  # validates :end_time
  validates :days, presence: true

end
