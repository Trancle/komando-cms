class ShowDlEpisode < ActiveRecord::Base
  include CW::ActsAs::Ordered::Model

  def self.acts_as_ordered_exclusivity_attribute_name; :show_id; end


  def self.find_top_available_for_show_in_order( show_id, limit = 5 )
    dls = self.find_in_order_for_exclusivity( show_id, { :limit => 50 }, 'DESC' )  # This may need to change, depending on how many items are in the DL listing
    opts = Episode.find_available_episode_options( {:limit => 50 } )
    opts[:conditions][0] << ' AND episodes.id IN (' + dls.map{|t| '?'}.join(',') + ')' unless dls.empty?
    dls.each do |dl|
      opts[:conditions] << dl.episode_id
    end
    eps = Episode.all(opts)
    sorted = []
    dls.each do |dl|
      ep = eps.find{|e| e.id.eql?(dl.episode_id) }
      sorted << ep if ep
      break if sorted.size >= limit
    end
    sorted
  end


  belongs_to :episode
  belongs_to :show, :foreign_key => :show_id
end
