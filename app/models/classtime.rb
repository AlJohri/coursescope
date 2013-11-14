class Classtime < ActiveRecord::Base
  belongs_to :course
  belongs_to :classroom

  serialize :start, Tod::TimeOfDay
  serialize :end, Tod::TimeOfDay

  validates :course_id, presence: true
  validates :classroom_id, presence: true
  validates :start, presence: true
  validates :end, presence: true
  validates :days, presence: true # must be between 1 and 16

end
