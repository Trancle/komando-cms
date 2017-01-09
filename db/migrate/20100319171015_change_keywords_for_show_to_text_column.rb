class ChangeKeywordsForShowToTextColumn < ActiveRecord::Migration
  def self.up
		change_column :shows, :keywords, :text
  end

  def self.down
		change_column :shows, :keywords, :string
  end
end
