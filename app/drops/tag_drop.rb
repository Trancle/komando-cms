class TagDrop < BaseDrop

  def initialize( ptag )
    @tag = ptag
  end

  def tag
    @tag.tag
  end
  alias_method :name, :tag
  alias_method :to_s, :tag

end