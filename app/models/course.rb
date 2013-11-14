class Course < ActiveRecord::Base
  belongs_to :term
  belongs_to :department

  has_and_belongs_to_many :careers
  has_and_belongs_to_many :instructors

  has_many :classtimes
  has_many :classrooms, :through => :classtimes

  self.primary_key= :id

  # has_many :requirements
  # has_many :prerequisites, :through => requirements

  # has_many :inverse_requirements, :class_name => "Requirement", :foreign_key => "prerequisite_id"
  # has_many :inverse_prerequisites, :through => :inverse_requirements, :source => :course

  validates :id, presence: true
  validates :title, presence: true
  validates :number, presence: true
  validates :section, presence: true
  validates :status, presence: true
  validates :category, presence: true
  validates :term, presence: true
  validates :department, presence: true

end
