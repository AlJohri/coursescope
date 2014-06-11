class Api::CoursesController < Api::BaseController

  def index
    render json: Course.all
  end

  def show
    render json: course.as_json(:include => [:classtimes, :instructors, :classrooms])
  end

  # Sample URL
  # http://localhost:3000/api/courses/scrape?department=EECS&term=4540
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
