class CreateLinkShowWithShowCategories < ActiveRecord::Migration
	include CW::ActsAs::Categorized::LinkMigration
  def self.up
    create_link_categorizeable_with_categories :link_show_with_show_categories
  end

  def self.down
    drop_table :link_show_with_show_categories
  end
end
