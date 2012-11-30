

class Manager::GalleriesController < ManagerController
  
  def destroy
    @g = Gallery.find params[:id]
    @g.is_trash = 1
    
    if @g.save
      flash[:notice] = 'Success'
    else
      flash[:error] = 'No Luck'
    end
    
    redirect_to manager_galleries_path
  end
  
  def index
    @galleries = Gallery.fresh
    
    if '1' == params[:public]
      @galleries = @galleries.public
    end
    
    if '1' == params[:done]
      @galleries = @galleries.done
    end
    
    @galleries = @galleries.page( params[:galleries_page] ).per(10)

    if params[:short_list]
      render 'index_short'
    else
      render
    end
  end
  
  def all_photos
    @photos = Photo.all
    
  end
  
  def show
    @gallery = Gallery.where( :galleryname => params[:id] ).first
    @galleries = Gallery.list
    
  end
  
  def new
    @gallery = Gallery.new
  end
  
end