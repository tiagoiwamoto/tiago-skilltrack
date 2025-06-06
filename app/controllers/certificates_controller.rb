class CertificatesController < ApplicationController
  before_action :set_certificate, only: %i[ show edit update destroy ]

  # GET /certificates or /certificates.json
  def index
    @certificates = Certificate.all
  end

  # GET /certificates/1 or /certificates/1.json
  def show
  end

  # GET /certificates/new
  def new
    @certificate = Certificate.new
  end

  # GET /certificates/1/edit
  def edit
  end

  # POST /certificates or /certificates.json
  def create
    @certificate = Certificate.new(certificate_params.except(:image))
    if params[:certificate][:image]
      image = params[:certificate][:image]
      uuid = SecureRandom.uuid
      ext = File.extname(image.original_filename)
      new_filename = "#{uuid}#{ext}"
      original_path = Rails.root.join("public/uploads", new_filename)
      FileUtils.mkdir_p(File.dirname(original_path))
      File.binwrite(original_path, image.read)
      @certificate.image_src = "/uploads/#{new_filename}"

      # Gerar thumb
      thumb_filename = "thumb_#{uuid}#{ext}"
      thumb_path = Rails.root.join("public/uploads", thumb_filename)
      ImageProcessing::MiniMagick
        .source(original_path)
        .resize_to_limit(200, 200)
        .call(destination: thumb_path)
      @certificate.image_src_thumb = "/uploads/#{thumb_filename}"
    end

    respond_to do |format|
      if @certificate.save
        format.html { redirect_to @certificate, notice: "Certificate was successfully created." }
        format.json { render :show, status: :created, location: @certificate }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @certificate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /certificates/1 or /certificates/1.json
  def update
    if params[:certificate][:image]
      # Remover imagens antigas
      FileUtils.rm_f(Rails.root.join("public", @certificate.image_src)) if @certificate.image_src.present?
      FileUtils.rm_f(Rails.root.join("public", @certificate.image_src_thumb)) if @certificate.image_src_thumb.present?

      image = params[:certificate][:image]
      uuid = SecureRandom.uuid
      ext = File.extname(image.original_filename)
      new_filename = "#{uuid}#{ext}"
      original_path = Rails.root.join("public/uploads", new_filename)
      FileUtils.mkdir_p(File.dirname(original_path))
      File.binwrite(original_path, image.read)
      @certificate.image_src = "/uploads/#{new_filename}"

      # Gerar thumb
      thumb_filename = "thumb_#{uuid}#{ext}"
      thumb_path = Rails.root.join("public/uploads", thumb_filename)
      ImageProcessing::MiniMagick
        .source(original_path)
        .resize_to_limit(200, 200)
        .call(destination: thumb_path)
      @certificate.image_src_thumb = "/uploads/#{thumb_filename}"
    end

    respond_to do |format|
      if @certificate.update(certificate_params.except(:image))
        format.html { redirect_to @certificate, notice: "Certificate was successfully updated." }
        format.json { render :show, status: :ok, location: @certificate }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @certificate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /certificates/1 or /certificates/1.json
  def destroy
    @certificate.destroy!

    respond_to do |format|
      format.html { redirect_to certificates_path, status: :see_other, notice: "Certificate was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_certificate
      @certificate = Certificate.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def certificate_params
      params.expect(certificate: [ :title, :earn_date, :expire_date, :image_src, :image_src_thumb ])
    end
end
