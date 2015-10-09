class PhotosController < ApplicationController
  def show
    @photo = Photo.find(params[:id])
  end

  def new_form

  end

  def create_row
    photo = Photo.new
    photo.source = params[:the_source]
    photo.caption = params[:the_caption]
    photo.save
    redirect_to "/photos/new"
  end

  def index
    @photos = Photo.all
  end
end
