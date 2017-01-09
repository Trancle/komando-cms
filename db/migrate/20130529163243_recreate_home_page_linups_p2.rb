class RecreateHomePageLinupsP2 < ActiveRecord::Migration
  include CW::ActsAs::Ordered::Migration
  def self.up
    create_table :show_dl_episodes do |t|
      t.column :episode_id, :integer, :null => false
    end
    add_order_with_exclusivity( 'ShowDlEpisode', :acts_as_ordered_order, :show_id )
  end

  def self.down
    drop_table :show_dl_episodes
  end
end
