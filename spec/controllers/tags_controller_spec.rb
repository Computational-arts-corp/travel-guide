require 'spec_helper'
describe TagsController do
  render_views

  before :each do
    User.all.each { |c| c.remove }
    @user = FactoryGirl.create :user
    @anon = FactoryGirl.create :anon

    Tag.all.each { |c| c.remove }
    @feature_tags = FactoryGirl.create_list( :feature_tag, 5 )
    @tags = FactoryGirl.create_list( :tag, 3 )
    @t = FactoryGirl.create :tag_local
    @tt = FactoryGirl.create :tag_pi
    @tt.parent_tag = @t
    @tt.save

    Report.clear
    @r = FactoryGirl.create :r1
    @r.tag = @tags[0]
    @r.save

    Gallery.clear
    @g = FactoryGirl.create :gallery
    @g.tag = @tags[0]
    @g.save
  end

  describe 'index' do
    it 'should GET list of topics' do
      get :index
      response.should be_success
    end

    it 'should have non-feature topics' do
      get :index
      assigns( :tags ).should_not eql nil
    end

    it 'only has public tags' do
      get :index
      assigns( :tags ).each do |tag|
        tag.is_public.should eql true
      end
      assigns( :feature_tags ).each do |tag|
        tag.is_public.should eql true
      end
    end

    it 'should have non-parent tags' do
      get :index
      tags = assigns :tags

      Tag.all.length.should_not eql tags.length
      tags.each do |tag|
        tag.parent_tag.should eql nil
      end
    end

    it 'should display at least one child tag' do
      get :index
      response.should render_template('tags/index')
    end
    
    it 'displays application_mini layout by default' do
      get :index
      response.should render_template('layouts/application_mini')
    end
  end

  describe 'show' do
    it 'GETs show' do
      get :show, :name_seo => @tt.name_seo
      response.should be_success
      response.should render_template('tags/show')
      assigns(:tag).should_not be nil
      assigns(:newsitems).should_not be nil
      assigns(:features).should_not be nil
      assigns(:videos).should_not be nil
      assigns(:reports).should_not be nil
      assigns(:galleries).should_not be nil
      assigns(:children_tags).should_not be nil
    end

    it 'displays galleries in reverse chrono order' do
      get :show, :name_seo => @tt.name_seo
      gs = assigns(:galleries)
      gs.each_with_index do |g, idx|
        if idx+1 != gs.length
          g.created_at.should be >= gs[idx+1]
        end
      end
    end

    it 'displays application_mini layout by default' do
      get :show, :name_seo => @tt.name_seo
      response.should render_template('layouts/application_mini')
    end
    
  end

end
