class HomePageBlockShowDl < HomePageBlock
  ffma_create_attribute 'type_data', 'show_id', :integer

  def episodes
    ShowDlEpisode.find_top_available_for_show_in_order( self.show_id, 5 )
  end
end
