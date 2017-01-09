class ShowTag < ActiveRecord::Base
  validates_presence_of :tag
  validates_length_of :tag, :allow_nil => false, :in => 1..64
  has_many :show_taggings
  has_many :shows, :through => :show_taggings
end