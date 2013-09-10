require 'spec_helper'
describe GalleriesController do
  before :each do
    Photo.all.each { |ph| ph.remove }

    Report.all.each { |c| c.remove }

    Tag.all.each { |c| c.remove }
    @tag = FactoryGirl.create :tag
    
    User.all.each { |c| c.remove }
    @user = FactoryGirl.create :user
    @piousbox = FactoryGirl.create :piousbox

    City.all.each { |c| c.remove }
    @city = FactoryGirl.create :rio

    Gallery.all.each { |g| g.remove }
    @g = FactoryGirl.create :gallery
    @g.city = City.all.first
    @g.save
    @g1 = FactoryGirl.create :g1
    @g2 = FactoryGirl.create :g2

    photos = Photo.all[0...4]
    photos.each do |photo|
      photo.gallery = @g
      photo.save
    end

    @ph1 = Photo.create :user => @user, :name => 'ph1'
    @ph2 = Photo.create :user => @user, :name => 'ph2'
    @ph3 = Photo.create :user => @user, :name => 'ph3'

  end

  describe 'not found' do
    it 'should display gallery-not-found' do
      Gallery.where( :galleryname => 'g' ).each { |g| g.remove }
      get :show, :galleryname => 'g', :locale => :en
      response.should be_redirect
    end
  end

  describe 'search' do
    it 'should search' do
      sign_in :user, @user
      post :search, :search_keyword => 'yada'
      response.should render_template('index')
      assigns(:galleries).should_not eql nil
    end
  end

  describe 'show' do
    it 'redirects from id to galleryname path' do
      get :show, :id => @g.id, :locale => :en
      response.should be_redirect
      response.should redirect_to(gallery_path(@g.galleryname, 0))
      
      get :show, :galleryname => @g.galleryname, :locale => :en
      response.should be_success
    end

    it 'GETs show' do
      Photo.all.length.should >= 2
      Photo.all.each do |ph|
        @g.photos << ph
      end
      @g.save
      @g.photos.length.should >= 2
      get :show, :galleryname => @g.galleryname, :locale => :en
      response.should be_success
      response.should render_template('galleries/show')
      assigns(:related_galleries).should_not eql nil
    end

    it 'renders cities layout' do
      @g.galleryname.should_not eql nil
      @g.city.name.should_not eql nil
      get :show, :galleryname => @g.galleryname, :layout => 'cities', :locale => :en
      response.should be_success
      # the cities layout actually errors out
      response.should render_template('layouts/application')
    end

    it 'shows long' do
      get :show, :galleryname => @g.galleryname, :style => 'show_long', :locale => :en
      response.should render_template('show_long')
    end

    it 'shows photo' do
      @g.galleryname.should_not eql nil
      get :show, :galleryname => @g.galleryname, :locale => :en
      response.should render_template('show')
      assigns( :photos ).should_not eql nil
    end

    it 'does not display cities layout' do
      get :show, :galleryname => @g.galleryname, :layout => 'cities', :locale => :en
      response.should render_template('layouts/application')
    end

    it 'shows only non-trash photos' do
      get :show, :galleryname => @g.galleryname, :locale => :en
      assigns(:photos).each do |photo|
        photo.is_trash.should eql false
      end
    end

    it 'redirects to first image if index of photo is out of bounds' do
      get :show, :galleryname => @g.galleryname, :photo_idx => 100
      response.should be_redirect
      response.should redirect_to("/en/galleries/show/#{@g.galleryname}/0")
    end

  end

  describe 'set show style' do
    it 'does' do
      sign_out :user
      @g.is_public.should eql true
      @g.is_trash.should eql false
      get :show, :galleryname => @g.galleryname, :locale => :en
      get :show, :galleryname => @g.galleryname, :locale => :en
      response.should render_template('show')
    end
  end
  
  describe 'index' do
    it 'gets galleries, created_at order' do
      get :index, :format => :json
      response.should be_success
      
      gs = assigns(:galleries)
      gs.should_not be nil
      gs.each do |g|
        g.is_public.should eql true
        g.username.should_not eql nil
      end
    end

  end

  describe 'create' do
    it 'creates newsitem for city' do
      sign_in :user, @user

      old_n_newsitems = City.find( @city.id ).newsitems.all.length

      g = { :is_public => true, :name => 'Name', :galleryname => 'galleryname', :user => User.all.first, :city_id => @city.id }
      post :create, :gallery => g

      # and non-public
      g = { :is_public => false, :name => 'Name', :galleryname => 'galleryname', :user => User.all.first, :city_id => @city.id }
      post :create, :gallery => g

      new_n_newsitems = City.find( @city.id ).newsitems.all.length
      ( new_n_newsitems - 1 ).should eql old_n_newsitems
    end
  end
  
end
