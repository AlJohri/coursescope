class Classtime < ActiveRecord::Base
  belongs_to :course
  belongs_to :classroom

  serialize :start_time, Tod::TimeOfDay
  serialize :end_time, Tod::TimeOfDay

  validates :course_id, presence: true
  validates :classroom_id, presence: true
  # validates :start_time
  # validates :end_time
  validates :days, presence: true

  def convert_days(days_int)
      days = []
      days_bitvector = days_int.to_s(2).split('')
      days_bitvector.each_with_index { |day, i|
        if i == 0 and day == "1"
          days.append('Sunday')
        elsif i == 1 and day == "1"
          days.append('Monday')
        elsif i == 2 and day == "1"
          days.append('Tuesday')
        elsif i == 3 and day == "1"
          days.append('Wednesday')
        elsif i == 4 and day == "1"
          days.append('Thursday')
        elsif i == 5 and day == "1"
          days.append('Friday')
        elsif i == 6 and day == "1"
          days.append('Saturday')
        end
      }
      days
  end

  def serializable_hash(options={})
    x = super(options)
    x['days'] = convert_days(x['days'])
    x
  end

end
