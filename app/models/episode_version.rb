class EpisodeVersion < ActiveRecord::Base
	include CW::ActsAs::Versioned::VersionedModel
	include CW::ActsAs::Cacheable

	attr_protected :editor_id
	attr_readonly :editor_id
	belongs_to :episode, :foreign_key => 'version_stub_id'

	belongs_to :editor, :class_name => 'User', :foreign_key => :editor_id
	belongs_to :episode_still_image, :class_name => 'PublicImage'

	validates_presence_of :title
	validates_length_of :title, :allow_nil => true, :allow_blank => false, :in => 1..1024
	
	validates_presence_of :description
	validates_length_of :description, :allow_nil => true, :allow_blank => true, :maximum => 20480

	validates_numericality_of :episode_number, :allow_nil => true, :only_integer => true

	validates_numericality_of :season_number, :allow_nil => true, :only_integer => true

	validates_presence_of :editor_id
	validates_numericality_of :editor_id, :only_integer => true

	validates_length_of :version_comment, :allow_blank => false, :allow_nil => false, :in => 5..4000

	acts_as_cacheable_cache_method( :version_number )

	liquid_methods :title, :description, :episode_number, :season_number


	def editor_or_deleted
		e = self.editor
		return UserDeleted.new if e.nil?
		e
	end

	def image_still_hash
		if self.has_image_still_hash?
			self.episode_still_image.file_hash
		else
			''
		end
	end

	def has_image_still_hash?
		self.episode_still_image and self.episode_still_image.file_hash and !self.episode_still_image.file_hash.empty?
	end

	def image_still_hash=( v )
		if !v.nil? and !v.empty?
			pi = PublicImage.first( :conditions => ['file_hash LIKE ?',"#{v}%"], :readonly => true )
			self.episode_still_image_id= pi.id unless pi.nil?
		end
	end


	def before_save
		self.url_title = Show.urlize( self.title )
    self.updated_at = Time.now.utc
	end

	def still_image_virtual_path
    begin
      unless self.episode_still_image.nil?
        self.episode_still_image.virtual_path
      else
        nil
      end
    rescue
      nil
    end
	end

	def still_image_alt
    begin
      unless self.episode_still_image.nil?
        self.episode_still_image.alt_text
      else
        nil
      end
    rescue
      nil
    end
  end

  def still_image_ext
    begin
      unless self.episode_still_image.nil?
        self.episode_still_image.file_extension
      else
        nil
      end
    rescue
      nil
    end
  end

end
