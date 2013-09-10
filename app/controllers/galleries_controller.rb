class GalleriesController < ApplicationController

  # caches_page :index, :show
  # before_filter :redirect_mobile_user, :only => [ :show ]

  rescue_from Mongoid::Errors::DocumentNotFound do
    flash[:error] = 'Gallery not found.'
    redirect_to galleries_path
  end

  def index
    authorize! :index, Gallery.new
    @galleries = Gallery.where( :is_public => true, :is_trash => false, :site => @site ).order_by( :created_at => :desc )

    if params[:cityname]
      city = City.where( :cityname => params[:cityname] ).first
      @galleries = @galleries.where( 'city' => city )
    end

    if params[:my]
      @galleries = @galleries.where( :user => current_user )
    end

    @galleries = @galleries.page( params[:galleries_page] )

    respond_to do |format|
      format.html do
        render
      end
      format.json do
        @g = []
        @galleries.each do |gallery|
          if gallery.photos[0]
            gallery[:photo_url] = gallery.photos[0].photo.url(:thumb)
          else
            gallery[:photo_url] = ''
          end
          gallery[:username] = gallery.user.username
          gallery.photos = gallery.photos.all
          @g.push gallery
        end
        render :json => @g
      end
    end
  end

  def show
    if params[:id]
      @g = Gallery.find params[:id]
      authorize! :not_found, @g
      if @g.galleryname.blank?
        @g.galleryname = @g.name.to_simple_string
        @g.save
      end
      redirect_to gallery_path(@g.galleryname, 0)
    else
      if @gallery = Gallery.where( :galleryname => params[:galleryname] ).first
        authorize! :show, @gallery
        @photos = @gallery.photos.where( :is_trash => false )
        @related_galleries = Gallery.where( :is_trash => false, :tag => @gallery.tag, :is_public => true,
                                            :site => @site ).page( params[:related_galleries_page] )
        unless @gallery.city.blank?
          @city = @gallery.city
          @galleryname = @gallery.galleryname
        end
        
        photo_idx = params[:photo_idx]
        if !photo_idx.blank? && ( photo_idx.to_i > (@photos.length-1).to_i )
          redirect_to gallery_path(@gallery.galleryname, 0)
        else
          respond_to do |format|
            format.html do
              action = Gallery.actions.include?( params[:style] ) ? params[:style] : 'show'
              render :action => action
            end
            format.mobile do
              render :action => 'show_long'
            end
            format.tablet do
              render :action => 'show_long'
            end
              format.json do
              photos = []
              @gallery.photos.all.each do |ph|
                p = { :thumb => ph.photo.url(:thumb), :large => ph.photo.url(:large) }
                photos.push p
              end
              @gallery[:photoss] = photos
              
              unless 0 == @gallery.photos.length
                @gallery[:photo_url] = @gallery.photos[0].photo.url(:thumb)
              end
              @gallery[:photo_url] ||= ''

              render :json => @gallery
            end
          end
        end
        
      else
        authorize! :not_found, Gallery.new
        flash[:error] = 'Gallery not found'
        redirect_to :action => :index
      end
    end
  end
  
  def new
    @gallery = Gallery.new
    authorize! :new, @gallery

    @venues_list = Venue.all.list

    respond_to do |format|
      format.html do
        render
      end
      format.json { render :json => @gallery }
    end
  end

  def create
    @gallery = Gallery.new(params[:gallery])
    @gallery.user = @current_user
    authorize! :create, @gallery

    if @gallery.save
      flash[:notice] = 'Success'
      redirect_to my_galleries_path
    else
      flash[:error] = 'No Luck.'
      @venues_list = Venue.all.list
      render :action => :new
    end

    
  end

  def edit
    if params[:id]
      @gallery = Gallery.find( params[:id] )
    else
      @gallery = Gallery.where( :galleryname => params[:galleryname] ).first
    end
    authorize! :edit, @gallery
    
    @cities = City.list
    @venues_list = Venue.all.list
  end

  def update
    @g = Gallery.find params[:id]
    authorize! :update, @g
    
    if @g.update_attributes params[:gallery]
      flash[:notice] = 'Success'
    else
      flash[:error] = 'No Luck'
    end
    redirect_to galleries_path
  end
  
  def search
    authorize! :search, Gallery.new
    
    @galleries = Gallery.where( :user => current_user, :name => /#{params[:q]}/i ).page( params[:galleries_page] )
    
    render :action => :index
  end

  def set_show_style
    authorize! :set_show_style, Gallery.new
    cookies[:galleries_show_style] = params[:style]
    flash[:notice] = 'Attempted setting display style for galleries/show'
    redirect_to request.referrer
  end
  
end


