
require 'spec_helper'

describe PhotosController do

  before :each do
    
    Tag.all.each { |c| c.remove }

    User.all.each { |c| c.remove }
    @user = FactoryGirl.create :user
    @simple = FactoryGirl.create :simple
    @user_2 = FactoryGirl.create :user_2
    @manager = FactoryGirl.create :manager
    @piousbox = FactoryGirl.create :piousbox

    City.all.each { |c| c.remove }
    @city = FactoryGirl.create :rio

    Report.all.each { |c| c.remove }
    @r1 = FactoryGirl.create :r1
    @r1.city = @city
    @r1.save

    @r9 = FactoryGirl.create :r9
    @r9.city = @city
    @r9.save

    sign_in @user

  end

  describe 'to newsitem' do

    it 'adds newsitem if a new public photo is created in the city' do
      city = City.first

      assert_equal 0, city.newsitems.length
      photo = { :city_id => city.id, :is_public => true, :name => 'bhal bbgf' }
      post :create, :photo => photo
      
      assert_equal 1, City.where( :cityname => city.cityname ).first.newsitems.length

    end

    it 'is put in newsitems of creator and viewer' do
      n_user_news = @user.newsitems.length
      n_simple_news = @simple.newsitems.length
      n_user_2_news = @user_2.newsitems.length
      photo = { :descr => 'lalala', :viewer_ids => [ @simple.id, @user_2.id ] }
      post :create, :photo => photo

      ( @user.newsitems.length - n_user_news ).should eql 1
      ( @simple.newsitems.length - n_simple_news  ).should eql 1
      ( @user_2.newsitems.length - n_user_2_news  ).should eql 1
    end

  end

  describe 'show' do

    it 'shows only to created and viewer' do
      ph = Photo.new
      ph.is_public = false
      ph.user = @user_2
      ph.viewer_ids = [ @simple.id, @piousbox.id ]
      flag = ph.save
      flag.should eql true

      sign_out :user
      sign_in @manager
      get :show, :id => ph.id
      response.should be_redirect

      sign_out :user
      sign_in @piousbox
      session[:current_user] = @piousbox
      get :show, :id => ph.id
      response.should be_success

      sign_out :user
      sign_in @simple
      get :show, :id => ph.id
      response.should be_success
    end
    
  end

end


