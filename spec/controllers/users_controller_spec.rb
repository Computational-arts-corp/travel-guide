require 'spec_helper'
describe UsersController do
  before :each do
    User.all.each { |d| d.remove }
    @user = FactoryGirl.create :user

    Tag.all.each { |d| d.remove }
    @tag = FactoryGirl.create :user_tag

    Report.clear
    @r1 = FactoryGirl.create :r1
    @r2 = FactoryGirl.create :r2
    @r3 = FactoryGirl.create :r3
    @r1.tag = @tag && @r1.save
    @r1.user = @user
    @r1.save
    @r3.tag = @tag && @r3.save
    @r3.user = @user
    @r3.save
  end
  
  describe 'reports' do
    it 'should show reports' do
      n_reports = Report.where( :user => @user ).length
      get :reports, :username => @user.username
      response.should be_success
      response.should render_template('users/reports')
      rs = assigns(:reports)
      rs.should_not be nil
      rs.length.should > 1
      rs.length.should eql n_reports
    end

    it 'should show one report' do
      get :report, :name_seo => @user.reports.first.name_seo, :username => @user.username
      response.should be_success
      response.should render_template('users/report')
      assigns( :report ).should_not eql nil
      assigns( :report ).user.should eql @user
    end
  end

  describe 'galleries' do
    it 'should list galleries' do
      get :galleries, :username => @user.username
      response.should be_success
      assigns( :galleries ).should_not eql nil
    end

    it 'should show gallery' do
      Gallery.all.each { |g| g.remove }
      @g = FactoryGirl.create :gallery
      @g.galleryname = 'a'
      @g.name = 'Name'
      @g.user = @user
      @g.is_public = true
      flag = @g.save
      puts! @g.errors
      ( flag ).should eql true
      
      get :gallery, :username => @user.username, :galleryname => @user.galleries.first.galleryname
      response.should be_success
      assigns( :gallery ).should_not eql nil
    end
  end

  describe 'organizer' do
    it 'should GET organizer' do
      sign_in :user, @user
      get :organizer
      response.should be_success
      assigns(:cities_user).should_not eql nil
      response.should render_template('organizer')
      assigns(:current_user).should_not eql nil
    end

    it 'should redirect to login if the user is not logged in' do
      sign_out :user
      get :organizer
      response.should be_redirect
      response.should redirect_to( :action => 'sign_in' )
    end

    it 'should let edit user' do
      sign_in :user, @user
      user = { :id => @user.id, :github_path => 'http://github.com/piousbox', :display_ads => false }
      post :update, :user => user, :id => @user.id
      result = User.find @user.id
      result.github_path.should eql user[:github_path]
      result.display_ads.should eql user[:display_ads]
    end
  end

  describe 'github page' do
    it 'should show the github page inside piousbox' do
      sign_out :user
      get :github_page, :username => @user.username
      response.should be_success
      response.should render_template('github')
    end
  end

  describe 'profiles' do
    it 'should GET new profile' do
      sign_in :user, @user
      get :new_profile
      response.should be_success
      response.should render_template('users/new_profile')

      assigns(:user_profile).should_not eql nil
    end

    it 'sets current user as the owner of the profile when creating' do
      sign_in :user, @user
      @user.user_profiles.each { |p| p.remove }
      profile = { :education => 'education', :objectives => 'objectives', :lang => 'ru' }
      post :create_profile, :user_profile => profile
      User.find( @user.id ).user_profiles.length.should eql 1
    end
  end

  describe 'gallery' do
    it 'should have list of this users galleries' do
      get :galleries, :username => @user.username
      response.should render_template('users/galleries')
      assigns(:galleries).should_not eql nil
    end
  end

  describe 'report' do
    it 'should GET report of a user' do
      get :reports, :username => @user.username, :name_seo => @r1.name_seo
      response.should render_template('users/report')
    end
  end

  describe 'index' do
    it 'only shows users with a gallery or report' do
      get :index
      response.should render_template('users/index')
      us = assigns(:users)
      us.each do |u|
        if u.reports.length > 0
          ;
        elsif u.galleries.length > 0
          ;
        else
          false.should eql true
        end
      end
    end
  end

  describe 'about' do
    it 'should GET about' do
      sign_out :user
      get :about
      response.should be_success
      response.should render_template('users/about')
    end
  end

end
