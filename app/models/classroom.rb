class Classroom < ActiveRecord::Base
  has_many :classtimes
  has_many :courses, :through => classtimes

  self.primary_key= :id

  validates :title, presence: true
end
