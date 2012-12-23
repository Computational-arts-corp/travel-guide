

class ReportsController < ApplicationController

  load_and_authorize_resource
  
  #  caches_page :index
  #  caches_page :homepage
  #  caches_page :show
  #  cache_sweeper :report_sweeper
  
  def homepage
    @reports = Report.for_homepage :main_tag => @main_tag,
      :page => params[:page]
  end
  
  def new
    @report = Report.new
    @cities = City.list

    respond_to do |format|
      format.html do
        render :layout => 'organizer'
      end
      format.json { render :json => @report }
    end
  end

  def edit
    @report = Report.find(params[:id],
      :include => [:tags]
    )
    @cities = City.list
    @tags = Tag.list
    
    respond_to do |f|
      f.html
      f.json
    end
  end

  def create
    @report = Report.new params[:report]
    @report[:lang] = @parsed_locale
    @report.user = @current_user

    @report[:name_seo] = @report[:name].to_simple_string
    
    saved = false
    if @report.save
      saved = true
      
      if @report[:is_public] == 1
      
      
        @n = Newsitem.new
        @n[:city_id] = @report[:city_id]
        @n[:user_id] = @report[:user_id]
        @n[:date] = Time.now
        @n[:is_created] = 1
        @n[:some_id] = @report.id
        @n[:model_name] = 'Report'
        @n[:report_id] = @report.id
        @n.save!
      end
    end
    
    respond_to do |format|
      if saved
        format.html { redirect_to report_path(@report.name_seo), :notice => 'Report was successfully created (but newsitem, no information.' }
        format.json { render :json => @report, :status => :created, :location => @report }
      else
        format.html { render :action => "new" }
        format.json { render :json => @report.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @report = Report.find(params[:id])

    respond_to do |format|
      if @report.update_attributes(params[:report])

        format.html { redirect_to report_path(@report), :notice => 'Report was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @report.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def search
    
    @reports = Report.where( :name => /#{params[:keyword]}/i )

    if params[:my]
      @reports = @reports.where( :user => current_user)
    end

    @reports = @reports.page( params[:reports_page] )
    
    render :action => :index
  end
  
  def index
    @reports = Report.where( :lang => @parsed_locale ).fresh

    if params[:my]
      @reports = @reports.where( :user => current_user )
    else
      @reports = @reports.public
    end

    if params[:cityname]
      city = City.where( :cityname => params[:cityname] ).first
      @reports = @reports.where( :city => city )
    end

    @reports = @reports.page( params[:reports_page] )
    
    respond_to do |format| 
      format.html do
        render :layout => false
      end
      format.json do
        @r = []
        @reports.each do |r|
          unless r.photo.blank?
            r[:photo_url] = r.photo.photo.url(:thumb)
          end
          r.username ||= r.user.username
          r.username ||= ''
          r[:photo_url] ||= ''
          @r.push r
        end
        render :json => @r
      end
    end
  end
  
  def show
    
    unless params[:name_seo].blank?
      @report = Report.where( :name_seo => params[:name_seo] ).first
    else
      @report = Report.find params[:id]
    end

    respond_to do |format|
      format.html do

        if @report.tag && 'cac' == @report.tag.name_seo
          # if a CAC newsitem
          redirect_to cac_report_path(@report.name_seo)

        elsif @report.tag && @report.user.username == @report.tag.name_seo
          # if a characteristic tag
          redirect_to user_report_path(@report.name_seo)

        elsif @report.city.blank?
          render :layout => 'blog'

        else
          @city = @report.city
          render :layout => 'cities'
          
        end
      end
      
      format.json do
        if @report.photo
          @report[:photo_url] = @report.photo.photo.url(:small)
        else
          @report[:photo_url] = Photo.first.photo.url(:small)
        end
        @report.username = @report.user.username
        @report.username ||= ''
        render :json => @report
      end
    end
  end
  
end