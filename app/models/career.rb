class Career < ActiveRecord::Base
  has_and_belongs_to_many :courses

  self.primary_key= :id

  validates :id, presence: true
  validates :title, presence: true
end
