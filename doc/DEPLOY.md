# Deployment Instructions

The following instructions explain how to deploy the site from a fresh install

# Extract the code

Pick a location and extract the code

# Configuration of /config

* cp config/database.yml.sample config/database.yml
* cp temp-dir.rb.sample temp-dir.rb

## Configure /config/initializers

* cp administration_visibility.rb.sample administration_visibility.rb
* auth_controller_config.rb.sample auth_controller_config.rb
* mail_configuration.rb.sample mail_configuration.rb
* notification_exception_configuration.rb.sample notification_exception_configuration.rb
* session_store.rb.sample session_store.rb
* watch_token_secret.rb.sample watch_token_secret.rb

# Migrate

bundle exec rake migrate:db

# Install settings

bundle exec ruby script/console
Setting.create_settings

# Create default page layouts (optional)

bundle exec ruby script/console
PageLayout.create_default_layouts_for_home_show_watch

# Create premium page

mkdir -p private/pages
touch private/pages/premium_purchase_required.erb

## Customize the premium page

vim private/pages/premium_purchase_required.erb

# Create public images folder

mkdir public/managed_file_resource_images

# Start the instance
bundle exec ruby script/server
