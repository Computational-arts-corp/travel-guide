require 'spec_helper'
describe CitiesController do
  render_views
  before :each do
    City.all.each { |u| u.remove }
    @city = @sf = FactoryGirl.create :sf

    User.all.each { |f| f.remove }
    @user = FactoryGirl.create :user
    
    Report.all.each { |r| r.remove }
    @feature_pt_1 = FactoryGirl.create :feature_pt_1
    @feature_ru_1 = FactoryGirl.create :feature_ru_1
    @report = FactoryGirl.create :report

    Gallery.all.each { |g| g.remove }
    @gallery = FactoryGirl.create :gallery

    @request.host = 'piousbox.com'
  end

  describe 'index' do
    it 'GETs english index' do
      get :index
      response.should render_template('cities/index')
    end

    it 'GETs english index with set locale' do
      get :index, :locale => :en
      response.should render_template('cities/index')
    end

    it 'displays only pt reports when locale is pt' do
      get :index, :locale => 'pt'
      assigns(:locale).should eql 'pt'
      feature_reports = assigns(:feature_reports)
      feature_reports.should_not be nil
      feature_reports.each do |r|
        r.lang.should eql 'pt'
      end
    end

    it 'displays only ru reports when locale is pt' do
      get :index, :locale => 'ru'
      assigns(:locale).should eql 'ru'
      feature_reports = assigns(:feature_reports)
      feature_reports.should_not be nil
      feature_reports.each do |r|
        r.lang.should eql 'ru'
      end
    end

    it 'displays cities with 0 reports and non-0 galleries' do
      # there must be a non-feature city with no reports and yes galleries
      new_city = FactoryGirl.create :city_cccq
      new_city.reports.each { |r| r.remove }
      g = Gallery.all.first
      g.city = new_city
      g.save
      new_city = City.where( :is_feature => false ).first
 
      get :index, :locale => 'en'
      assigns(:cities).should_not eql []
      flag = false
      assigns(:cities).each do |city|
        if 0 == city.reports.length
          flag = true
        end
      end
      flag.should eql true
    end

  end

  describe 'profile' do
    it 'shows guide is there is a guide' do
      @city.guide = User.all.first
      @city.save
      u = User.all.first
      u.guide_city = @city
      u.save
      
      get :profile, :cityname => 'San_Francisco'
      response.should be_success
      assigns(:city).guide.should_not be nil
      assigns(:features).should_not be nil
    end

    it 'should get home' do
      get :profile, :cityname => 'San_Francisco'
      response.should be_success

      city = assigns(:city)
      city.cityname.should eql 'San_Francisco'

      rs = assigns(:reports)
      (0..rs.length-1).each do |idx|
        rs[idx].created_at.should be >= rs[idx+1].created_at
      end
    end

    it 'should show people' do
      get :users, :cityname => 'San_Francisco'
      response.should be_success
      assigns( :users ).should_not eql nil
    end

    it 'should show venues' do
      get :venues, :cityname => 'San_Francisco'
      response.should be_success
      assigns( :venues ).should_not eql nil
    end

    it 'should GET today' do
      get :today, :cityname => 'San_Francisco'
      response.should be_success
    end

  end
  
end
