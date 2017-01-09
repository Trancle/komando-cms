class EpisodeTag < ActiveRecord::Base
	validates_presence_of :tag
	validates_length_of :tag, :allow_nil => false, :in => 1..64
  has_many :episode_taggings
  has_many :episodes, :through => :episode_taggings
end
