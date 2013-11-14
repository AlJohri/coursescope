class Term < ActiveRecord::Base
  has_many :courses

  self.primary_key= :id

  validates :id, presence: true
  validates :title, presence: true
  validates :year, presence: true
end
