class Department < ActiveRecord::Base
	has_many :courses

  self.primary_key= :id

  validates :id, presence: true
  validates :title, presence: true
end
