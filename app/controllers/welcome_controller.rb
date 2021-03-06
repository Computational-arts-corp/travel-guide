class WelcomeController < ApplicationController
  skip_authorization_check
  before_filter :load_features
  before_filter :redirect_mobile_user, :only => [ :home ]

  # caches_page :help, :about, :privacy
  
  def set_city
    next_cityname = params[:user][:cityname]
    city = City.where( :cityname => next_cityname ).first
    if city.blank?
      session[:current_city] = nil
    else
      session[:current_city] = {
        :name => city['name_'+@locale.to_s],
        :cityname => city.cityname
      }
    end
    unless current_user.blank?
      current_user.current_city = city
      current_user.save
      flash[:notice] = 'Current city set.'
    else
      flash[:notice] = 'Current city set. Login to save your selection & customize other features of this website.'
    end
    redirect_to request.referrer
  end

  def help
    render :layout => @layout
  end

  def about
    render :layout => @layout
  end

  def privacy
    render :layout => @layout
  end

  def contact
    render :layout => @layout
  end

  def home
    case @domain
    when 'travel-guide.mobi', 'mobi.local'
      redirect_to :controller => :cities, :action => :index
    else
      redirect_to :controller => :sites, :action => :show, :domainname => @site.domain
    end
  end

end
