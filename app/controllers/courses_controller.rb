class CoursesController < ApplicationController
  before_action :set_course, only: %i[ show edit update destroy ]

  # GET /courses or /courses.json
  def index
    @courses = Course.all
  end

  # GET /courses/1 or /courses/1.json
  def show
  end

  # GET /courses/new
  def new
    @course = Course.new
  end

  # GET /courses/1/edit
  def edit
  end

  # POST /courses or /courses.json
  def create
    @course = Course.new(course_params.except(:image))
    if params[:course][:image]
      image = params[:course][:image]
      uuid = SecureRandom.uuid
      ext = File.extname(image.original_filename)
      new_filename = "#{uuid}#{ext}"
      path = "public/uploads/courses/#{params[:course][:school].to_s.downcase.gsub(/\s+/, "")}/#{new_filename}"
      FileUtils.mkdir_p(File.dirname(path))
      FileUtils.mkdir_p(File.dirname(path))
      File.binwrite(path, image.read)
      @course.image_src = "/uploads/courses/#{params[:course][:school].to_s.downcase.gsub(/\s+/, "")}/#{new_filename}"

      # Gerar thumb
      thumb_filename = "thumb_#{uuid}#{ext}"
      thumb_path = "public/uploads/courses/#{params[:course][:school].to_s.downcase.gsub(/\s+/, "")}/#{thumb_filename}"
      ImageProcessing::MiniMagick
        .source(path)
        .resize_to_limit(200, 200)
        .call(destination: thumb_path)
      @course.image_src_thumb = "/uploads/courses/#{params[:course][:school].to_s.downcase.gsub(/\s+/, "")}/#{thumb_filename}"
    end
    respond_to do |format|
      if @course.save
        format.html { redirect_to @course, notice: "Course was successfully created." }
        format.json { render :show, status: :created, location: @course }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /courses/1 or /courses/1.json

  def update
    if params[:course][:image]
      # Remover imagens antigas
      FileUtils.rm_f(Rails.root.join("public", @course.image_src)) if @course.image_src.present?
      FileUtils.rm_f(Rails.root.join("public", @course.image_src_thumb)) if @course.image_src_thumb.present?

      image = params[:course][:image]
      uuid = SecureRandom.uuid
      ext = File.extname(image.original_filename)
      new_filename = "#{uuid}#{ext}"
      path = "public/uploads/courses/#{params[:course][:school].to_s.downcase.gsub(/\s+/, "")}/#{new_filename}"
      FileUtils.mkdir_p(File.dirname(path))
      File.binwrite(path, image.read)
      @course.image_src = "/uploads/courses/#{params[:course][:school].to_s.downcase.gsub(/\s+/, "")}/#{new_filename}"

      # Gerar thumb
      thumb_filename = "thumb_#{uuid}#{ext}"
      thumb_path = "public/uploads/courses/#{params[:course][:school].to_s.downcase.gsub(/\s+/, "")}/#{thumb_filename}"
      ImageProcessing::MiniMagick
        .source(path)
        .resize_to_limit(200, 200)
        .call(destination: thumb_path)
      @course.image_src_thumb = "/uploads/courses/#{params[:course][:school].to_s.downcase.gsub(/\s+/, "")}/#{thumb_filename}"
    end
    respond_to do |format|
      if @course.save
        format.html { redirect_to @course, notice: "Course was successfully updated." }
        format.json { render :show, status: :created, location: @course }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1 or /courses/1.json
  def destroy
    @course.destroy!

    respond_to do |format|
      format.html { redirect_to courses_path, status: :see_other, notice: "Course was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def course_params
      params.expect(course: [ :title, :category, :earn_date, :school, :image_src, :image_src_thumb ])
    end
end
