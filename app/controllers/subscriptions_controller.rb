
class SubscriptionsController < ApplicationController

  skip_authorization_check
  
  def success
    ;
  end

  def new
    @subscription = Subscription.new

    respond_to do |format|
      format.html do
        render :layout => 'cac'
      end
      format.json { render :json => @subscription }
    end
  end

  def create
    @subscription = Subscription.new(params[:subscription])
    
    respond_to do |format|
      if @subscription.save
        format.html { render 'success' }
        format.json { render :json => @subscription, :status => :created, :location => @subscription }
      else
        format.html { render :action => "new" }
        format.json { render :json => @subscription.errors, :status => :unprocessable_entity }
      end
    end
  end

end
