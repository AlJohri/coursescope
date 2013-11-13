class Classtime < ActiveRecord::Base
  belongs_to :course
  belongs_to :classroom

  serialize :start, Tod::TimeOfDay
  serialize :end, Tod::TimeOfDay  
end
