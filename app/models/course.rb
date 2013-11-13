class Course < ActiveRecord::Base
  belongs_to :term
  belongs_to :department

  has_and_belongs_to_many :careers
  has_and_belongs_to_many :instructors
  has_and_belongs_to_many :classrooms

  has_many :requirements
  has_many :prerequisites, through :requirements

  has_many :inverse_requirements, :class_name => "Requirement", :foreign_key => "prerequisite_id"
  has_many :inverse_prerequisites, :through => :inverse_requirements, :source => :course

end
