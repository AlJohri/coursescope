class Api::CoursesController < ApplicationController

  def index
    render json: Course.all
  end

  # def create
  #   course = Course.create!(safe_params)
  #   render json: course, status: 201
  # end

  # def update
  #   course.update_attributes(safe_params)
  #   render nothing: true, status: 204
  # end

  # def destroy
  #   course.destroy
  #   render nothing: true, status: 204
  # end

  def show
    render json: course
  end

  # Sample URL
  # http://localhost:3000/api/courses/scrape?department=EECS&term=4530
  def scrape
    worker = CourseWorker.new
    doc = worker.get_courses(params)
    if doc
      courses = doc.search("span[id^='DERIVED_CLSRCH_DESCR200$']/text()").to_a
      render json: courses.map { |course| course = CGI.unescapeHTML(course.to_s).delete!("^\u{0000}-\u{007F}") }.to_json
      return
    end

    render json: 'error'
    #CourseWorker.perform_async()
    #render json: 'scraping has begun'
  end

  private

  def course
    @course ||= Course.find(params[:id])
  end

  def safe_params
    params.require(:course).permit()
  end

end
