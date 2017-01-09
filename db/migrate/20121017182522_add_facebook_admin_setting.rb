class AddFacebookAdminSetting < ActiveRecord::Migration
  def self.up
		SettingString.new( :name => 'Facebook Admin ID', :programmatic_name => "#{Setting.protected_programmatic_prefix}-facebook-admin-id", :description => 'This is the facebook ID for your facebook administrator page. This numeric ID allows you to track impressions and insights at: http://www.facebook.com/insights' ).save
  end

  def self.down
		SettingString.destroy_all( :programmatic_name => "#{Setting.protected_programmatic_prefix}-facebook-admin-id" )
  end
end
