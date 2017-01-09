class ExceptionNotification < ActionMailer::Base
  
 def exception_notification(exception,uri,controller_name,params,other_stuff = {})
     recipients ExceptionNotificationConfiguration.conf[:recipients]
     from       ExceptionNotificationConfiguration.conf[:from]
     subject    "Exception Notification"
     body       :exception => exception, :controller_name => controller_name, :params => params, :uri => uri, :other_stuff => other_stuff
	end


end
