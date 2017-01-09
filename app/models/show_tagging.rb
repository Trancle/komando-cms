class ShowTagging < ActiveRecord::Base
  validates_uniqueness_of :show_id, :scope => :tag_id
  belongs_to :tag, :class_name => 'ShowTag'
  belongs_to :show
end