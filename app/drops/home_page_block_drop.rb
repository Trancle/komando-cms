class HomePageBlockDrop < BaseDrop

  def initialize( block, episode_drops )
    @block = block
    @episode_drops = episode_drops
  end

  def machine_name
    @block.machine_name
  end

  def block_style
    @block.block_style
  end

  def type
    @block.type
  end

  def show_id
    @block.show_id
  end

  def episode_limit
    @block.episode_limit
  end

  def episodes
    @episode_drops
  end

end # HomePageBlock