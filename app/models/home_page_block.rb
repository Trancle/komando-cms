class HomePageBlock < ActiveRecord::Base
  include CW::ActsAs::Ordered::Model
  include FreeFormModelAttributeModel

  composed_of :type_data, :class_name => 'FreeFormModelAttribute', :mapping => %w(type_data to_composition)
  before_validation :commit_sub_configuration

  private
  def commit_sub_configuration
    self.type_data = self.type_data.dup
  end
  public

  validates_presence_of :machine_name
  validates_length_of :machine_name, :in => 1..255
  validates_uniqueness_of :machine_name
  validates_format_of :machine_name, :with => /\A[a-z0-9_]+\Z/


  validates_presence_of :block_style
  validates_length_of :block_style, :in => 1..255

  validates_presence_of :episode_limit
  validates_numericality_of :episode_limit, :only_integer => true
end
