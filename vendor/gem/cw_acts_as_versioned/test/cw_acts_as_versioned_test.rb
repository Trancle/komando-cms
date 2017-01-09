require 'test_helper'
require File.dirname(__FILE__)+"/../lib/cw_acts_as_versioned.rb"

# Create models
class Widget < ActiveRecord::Base
end

class CreateWidgets < ActiveRecord::Migration
  include CW::Acts::As::Versioned::Migration
  def self.up
    create_table :widgets do |t|
			# creates the stub class
      t.timestamps
    end
		create_versioned_table_named( :table_name => :widget_versions, :stub_id_column_name => :widget_id ) do |t|
			t.column :title, :string, :limit => 256
			t.column :description, :text
		end
  end

  def self.down
    drop_table :widgets
		drop_table :widget_versions
  end
end


class CwActsAsVersionedTest < ActiveSupport::TestCase
	def self.migration
		
	end

  # Replace this with your real tests.
  test "create_first_version" do
    flunk
  end
end
