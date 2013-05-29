require 'spec_helper'
describe Manager::ReportsController do
  before :each do
    Tag.clear
    
    User.all.each { |c| c.remove }
    @user = User.all[0]
    @admin = FactoryGirl.create :admin

    City.all.each { |c| c.remove }
    @city = FactoryGirl.create :rio

    Report.clear
    @r1 = FactoryGirl.create :r1
    @r1.city = @city
    @r1.save
    @r9 = FactoryGirl.create :r9
    @r9.city = @city
    @r9.save

    Gallery.all.each { |g| g.remove }
    @g = Gallery.create :name => 'a', :galleryname => 'bb', :user => User.all[0]
    
    sign_in @admin
    
    setup_sites
    @site = Site.where( :domain => 'test.host', :lang => 'en' ).first
  end

  describe 'show' do
    it 'should show a report with no photo' do
      r = Report.where( :photo => nil ).first
      r.should_not eql nil
      get :show, :id => r.id, :locale => :en
      response.should render_template('manager/reports/show')
      response.should be_success
    end
  end
  
  describe 'index' do
    it 'should index' do
      r = Report.all
      (r.length > 1).should eql true
     
      get :index
      response.should be_success
      assigns(:reports).should_not eql nil
    end

    it 'should not show trash in index' do
      @r2 = FactoryGirl.create :r2
      @r2.is_trash = true
      @r2.save.should eql true
      
      get :index
      assigns(:reports).each do |report|
        report.is_trash.should_not eql true
      end
    end
    
    it 'should search' do
      post :index, :report => { :city_id => @city.id }
      assigns(:reports).should_not eql nil
    end

    it 'searches' do
      k = 'b'
      get :index, :search_words => k
      assigns(:reports).each do |g|
        ( g.name.include? k ).should eql true
      end
    end
    
    it 'should display fresh' do
      get :index, :fresh => 1
      response.should be_success
      assigns(:reports).should_not be nil
      assigns(:reports).each do |r|
        r.is_trash.should be false
      end      
    end

    it 'should order by created-at' do
      get :index
      assigns(:reports).each_with_index do |r, idx|
        if idx + 1 == assigns(:reports).length
          break
        else
          assigns(:reports)[idx].created_at.should be >= assigns(:reports)[idx + 1].created_at
        end
      end
    end
    
    it 'should display public' do
      get :index, :public => 1, :locale => :en
      response.should be_success
      assigns(:reports).should_not eql nil
      assigns(:reports).each do |r|
        r.is_public.should be true
      end
    end

    it 'should display only reports of a locale' do
      get :index
      assigns(:reports).each do |r|
        r.lang.should eql 'en'
      end

      get :index, :locale => 'ru'
      assigns(:reports).each do |r|
        r.lang.should eql 'ru'
      end
    end

    it 'should get fullindex' do
      get :fullindex
      assigns(:reports).should_not eql nil
    end

  end
  
  describe 'create' do
    it 'puts features to homepage features' do
      old_n_features = @site.features.all.length
      post :create, :report => { :is_public => true, :is_feature => true,   :name => '1 balsdfkaposfgua sd f dsf d f' }
      post :create, :report => { :is_public => false, :is_feature => true,  :name => '2 balsdfkaposfgua sd f dsf d f' }
      post :create, :report => { :is_public => false, :is_feature => false, :name => '3 balsdfkaposfgua sd f dsf d f' }
      new_n_features = Site.find( @site.id ).features.all.length
      ( new_n_features - 1 ).should eql old_n_features
    end

    it 'lets you select author user' do
      get :new
      response.should be_success
      assigns(:users_list).should_not eql nil
      u3 = User.new( :username => 'u3', :email => 'u3@gmail.com', :name => 'u3', :password => 's1mple123' )
      u3.save || puts!( u3.errors )
      u3 = User.where( :username => 'u3' ).first
      post :create, :report => { :name => 'The Nexx', :user_id => u3 }
      result = Report.where( :name => 'The Nexx' ).first
      result.should_not eql nil
      result.user.should eql u3
    end

    it 'lets you select non-public tags' do
      get :new
      new_tag = Tag.new( :user => @user, :name => 'asdfgasdfgasdf', :is_public => false )
      new_tag.save || puts!( new_tag.errors )
      n_tags = Tag.where( :is_trash => false, :parent_tag => nil ).length
      assigns(:tags).length.should eql n_tags
    end
  end
  
end
