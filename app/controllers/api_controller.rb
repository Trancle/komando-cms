class ApiController < ApplicationController
  skip_filter :require_login
  skip_filter :require_administrator_user

  def record_email
    file_path = "/var/www/default/log/api-record-email.csv"
    email = (params['email'] || '').strip.gsub('"','""')
    record = Time.now.strftime('%Y-%m-%dT%H:%M:%s') + ',"' + email + '"'
    if request.post?
    begin
      if email[/[^@]+@[^.]+\..+/i]
        File.open(file_path,'a') do |f|
          f << record + "\n"
        end
        render :inline => "200 OK"
      else
        render :inline => "400 Invalid Input", :status => 400
      end

    end
    else
      render_error_403 and return
    end
  end
end