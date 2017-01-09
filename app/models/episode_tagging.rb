class EpisodeTagging < ActiveRecord::Base
  validates_uniqueness_of :episode_id, :scope => :tag_id
  belongs_to :tag, :class_name => 'EpisodeTag'
  belongs_to :episode
end