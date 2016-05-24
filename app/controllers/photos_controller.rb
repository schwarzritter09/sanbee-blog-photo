class PhotosController < ApplicationController
  before_action :set_photo, only: [:show, :photo_get]

  # GET /photos
  # GET /photos.json
  def index
    @photos = Photo.search(params[:photo_search]).page(params[:page]).per(20)
  end

  # GET /photos/1
  # GET /photos/1.json
  def show
  end

  # GET /photos/update_get
  # GET /photos/update_get.json
  def update_get
    @datetime = params[:lastdt]
    if @datetime.blank?
      @photos = Photo.all
    else
      @photos = Photo.update_get @datetime
    end
  end
  
  # GET /photo/:id/photo_get
  # GET /photo/:id/photo_get.json
  def photo_get
    send_file SanbeeBlogPhoto::Application.config.img_path_root + @photo.path, :disposition => "inline"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo = Photo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def photo_params
      params.require(:photo).permit(:path, :create_member_id)
    end
end
