class SystemNotificationController < ApplicationController
  unloadable
  layout 'base'
  protect_from_forgery :except => [:create, :users_since]
  
  def index
    @system_notification = SystemNotification.new
  end
  
  def create
    @system_notification = SystemNotification.new(params[:system_notification])
    if params[:system_notification][:time]
      @system_notification.users = SystemNotification.users_since(params[:system_notification][:time],
                                                                  {
                                                                    :projects => params[:system_notification][:projects]
                                                                  })
    end
    if @system_notification.deliver
      flash[:notice] = l('system_notification_was_successfully_sent') #"System Notification was successfully sent."
      redirect_to :action => 'index'
    else
      flash[:error] = "System Notification was not sent."
      render :action => 'index'
    end
  end
  
  def users_since
    if params[:system_notification] && params[:system_notification][:time] && !params[:system_notification][:time].empty?
      @users = SystemNotification.users_since(params[:system_notification][:time],
                                              {
                                                :projects => params[:system_notification][:projects]
                                              })
    end
    @users ||= []
    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.js { render :partial => 'users', :object => @users }
    end
  end
end
