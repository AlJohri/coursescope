class Api::CoursesController < Api::BaseController

  def index
    if params['days']
      render json: Course.joins(:classtimes).where(classtimes: {days: params['days']}).all
    else
      render json: Course.all
    end
  end

  def show
    render json: course.as_json(:include => [:classtimes, :instructors, :classrooms])
  end

  private

  def course
    @course ||= Course.find(params[:id])
  end

  def safe_params
    params.require(:course).permit()
  end

end
