class Manager::CitiesController < Manager::ManagerController
  before_filter :set_lists, :only => [ :new_newsitem, :create_newsitem ]
  before_filter :set_city, :only => [ :show, :edit ]

  def index
    authorize! :index, ManagerCity.new
    @cities = City.all
    @city = City.new
    @photo = Photo.new
  end
  
  def show
    authorize! :show, ManagerCity.new
    @city = City.find params[:id]
    @photo = Photo.new
  end
  
  def new
    authorize! :new, ManagerCity.new
    @city = City.new
    @photo = Photo.new
  end

  def create
    authorize! :create, ManagerCity.new
    @city = City.new params[:city]
    
    if @city.save
      flash[:notice] = 'Success'
      redirect_to manager_cities_path
    else
      flash[:error] = 'No Luck'
      render :action => :new
    end
  end

  def edit
    authorize! :edit, ManagerCity.new
    @city = City.find params[:id]
    @photo = Photo.new
  end
  
  def update
    authorize! :update, ManagerCity.new

    @city = City.find( params[:id] )

    @city.update_attributes params[:city]    
    
    if @city.save
      flash[:notice] = 'Success'
      redirect_to edit_manager_city_path @city.id
    else
      flash[:error] = 'No Luck. ' + @city.errors.inspect
      @newsitems = @city.newsitems.all.page( params[:newsitems_page] )
      @features = @city.features.all.page( params[:features_page] )
      @photo = Photo.new
      render :action => :edit
    end
  end

  def change_profile_pic
    authorize! :change_profile_pic, ManagerCity.new

    @city = City.find params[:id]
    
    @photo = Photo.new params[:photo]
    @photo.user = @current_user
    flag = @photo.save
    @city.profile_photo = @photo
    flagg = @city.save
    if flag && flagg
      flash[:notice] = 'Success'
    else
      flash[:error] = "No Luck. #{@photo.errors.inspect} #{@city.errors.inspect}"
      # puts! @photo.errors.inspect
      # puts! @city.errors.inspect
    end

    redirect_to manager_cities_path
  end

  def new_feature
    authorize! :new_feature, ManagerCity.new
    @city = City.find params[:city_id]
    @feature = Feature.new
  end

  def create_feature
    authorize! :create_feature, ManagerCity.new

    @city = City.find params[:city_id]
    @feature = Feature.new params[:feature]

    @city.features << @feature

    if @city.save
      flash[:notice] = 'Success.'
      redirect_to :action => :show, :id => @city.id
    else
      flash[:error] = 'No Luck. ' + @city.errors.inspect
      render :action => :new_feature
    end
  end

  def edit_feature
    authorize! :edit_feature, ManagerCity.new
    @city = City.find params[:city_id]
    @feature = @city.features.find params[:feature_id]

  end

  def update_feature
    authorize! :update_feature, ManagerCity.new

    @city = City.find params[:city_id]
    @feature = @city.features.find params[:feature_id]
    if @feature.update_attributes params[:feature]
      flash[:notice] = 'Success'
      redirect_to manager_cities_path
    else
      flash[:error] = 'No Luck. ' + @feature.errors.inspect
      render :action => :edit_feature
    end
  end

  def new_newsitem
    authorize! :new_newsitem, ManagerCity.new

    @newsitem = Newsitem.new
    @city = City.find params[:city_id]

  end

  def create_newsitem
    authorize! :create_newsitem, ManagerCity.new

    n = Newsitem.new params[:newsitem]
    n.report = Report.find params[:newsitem][:report_id] unless params[:newsitem][:report_id].blank?
    n.gallery = Gallery.find params[:newsitem][:gallery_id] unless params[:newsitem][:gallery_id].blank?
    n.photo = Photo.find params[:newsitem][:photo_id] unless params[:newsitem][:photo_id].blank?
    n.descr = params[:newsitem][:descr]

    @city = City.find params[:city_id]
    @city.newsitems << n

    if @city.save
      flash[:notice] = 'Success'
      redirect_to edit_manager_city_path( @city.id )
    else
      flash[:error] = 'No Luck. ' + @city.errors.inspect
      render :action => :new_newsitem

    end

  end

  private

  def set_city
    @city = City.find( params[:id] )
    @newsitems = @city.newsitems.order_by( :created_at => :desc ).page( params[:newsitems_page] )
    @features = @city.features.all.page( params[:features_page] )
  end

  def set_lists
    @list_reports = Report.all.list
    @list_galleries = Gallery.all.list
    @list_users = [['', nil]] + User.all.order_by( :name => :asc ).map { |u| [u.username, u.username] }
  end

end
