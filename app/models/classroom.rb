class Classroom < ActiveRecord::Base
  has_many :classtimes
  has_many :courses, :through => classtimes
end
