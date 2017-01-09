class ShowVersion < ActiveRecord::Base
	include CW::ActsAs::Versioned::VersionedModel
	def self.scheduled_version_klass; "ShowVersionSchedule".constantize; end
	include CW::ScheduledVersion::Version

	include CW::ActsAs::Cacheable

	attr_protected :editor_id
	attr_readonly :editor_id

	belongs_to :editor, :class_name => 'User', :foreign_key => :editor_id
	belongs_to :show_still_image, :class_name => 'PublicImage'
	belongs_to :show_splash_image, :class_name => 'PublicImage'

	validates_length_of :description, :allow_nil => true, :allow_blank => true, :maximum => 20480
	validates_presence_of :title
	validates_length_of :title, :allow_blank => false, :in => 1..1024

	validates_length_of :page_injected_css, :allow_blank => true, :allow_nil => true, :maximum => 20480
	validates_length_of :page_injected_javascript, :allow_blank => true, :allow_nil => true, :maximum => 20480
	validates_length_of :page_injected_html, :allow_blank => true, :allow_nil => true, :maximum => 20480
	validates_presence_of :editor_id
	validates_numericality_of :editor_id, :only_integer => true

	validates_length_of :availability_notes, :allow_blank => true, :allow_nil => true, :maximum => 1024

	validates_length_of :version_comment, :allow_blank => false, :allow_nil => false, :in => 5..4000

	acts_as_cacheable_cache_method( :version_number )

	liquid_methods :title, :description, :availability_notes

	def editor_or_deleted
		e = self.editor
		return UserDeleted.new if e.nil?
		e
	end


	def image_still_hash
		if self.show_still_image
			self.show_still_image.file_hash
		else
			''
		end
	end

	def image_still_hash=( v )
		if !v.nil? and !v.empty?
			pi = PublicImage.find( :first, :conditions => ['file_hash LIKE ?',"#{v}%"], :readonly => true )
			self.show_still_image_id= pi.id unless pi.nil?
		end
	end

	def image_splash_hash
		if self.show_splash_image
			self.show_splash_image.file_hash
		else
			''
		end
	end

	def image_splash_hash=( v )
		if !v.nil? and !v.empty?
			pi = PublicImage.find( :first, :conditions => ['file_hash LIKE ?',"#{v}%"], :readonly => true )
			self.show_splash_image_id= pi.id unless pi.nil?
		end
	end




	def before_save
		self.url_title = Show.urlize( self.title )
	end

end
