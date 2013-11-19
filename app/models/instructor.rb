class Instructor < ActiveRecord::Base
  has_and_belongs_to_many :courses

  self.primary_key= :id

  # validates :first_name, presence: true
  # validates :middle_name, presence: true
  # validates :last_name, presence: true
  # validates :category, presence: true
  # validates :email, presence: true
  # validates :website, presence: true    

end
