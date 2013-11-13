class Requirement < ActiveRecord::Base
  belongs_to :course
  belongs_to :prerequisite, :class_name => "Course"
end
