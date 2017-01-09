class HomePageBlockFiltered < HomePageBlock
  ffma_create_attribute 'type_data', 'show_id', :integer
  ffma_create_attribute 'type_data', 'order_by_string', :string


  def episodes
    Episode.all(Episode.find_available_episode_for_show_options( self.show_id, { :limit => self.episode_limit, :order => self.order_by_string } ))
  end
end
