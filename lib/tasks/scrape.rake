require_relative "../../app/workers/course_worker"
require_relative "../../app/workers/description_worker"

namespace :scrape do
  task :courses => :environment do
    worker = CourseWorker.new
    worker.perform()
  end
  # task :descriptions => :environment do
  #   description = DescriptionWorker.new
  #   description.scrape_descriptions
  # end 
end