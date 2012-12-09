
require 'spec_helper'

describe UsersController do
  
  before :each do
    User.all.each { |d| d.remove }

    @user = FactoryGirl.create :user
    
  end
  
  describe 'photos' do
    it 'shows my fucking photos' do
      sign_in :user, @user
      
      get 'photos'
      response.should be_success
      response.should render_template('photos')
      
    end

    it 'should show articles' do
      get :reports, :username => @user.username
      response.should be_success
      response.should render_template(:reports)
      rs = assigns(:reports)
      rs.should_not be nil
      rs.length.should be >= 1

      rs.each do |r|
        r.is_trash.should eql false
        r.is_public.should eql true
      end
      
    end
  end
end