class CreateShowCategories < ActiveRecord::Migration
	include CW::ActsAs::Categorized::BaseMigration
  def self.up
    create_categories :show_categories
  end

  def self.down
    drop_table :show_categories
  end
end
