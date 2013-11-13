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

  def scrape
    CourseWorker.perform_async()
    render json: 'scraping has begun'
  end

  private

  def course
    @course ||= Course.find(params[:id])
  end

  def safe_params
    params.require(:course).permit()
  end

end
