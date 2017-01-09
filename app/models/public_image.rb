class PublicImage < ActiveRecord::Base
	include CW::ManagedFileResource::ModelPublicImage
	include ActionView::Helpers::TextHelper

# short-cut as these are public: by-passes need for render controller, because it's hash based, very hard to guess
	def virtual_path
		self.class.local_file_path_from_hash( Pathname.new('/managed_file_resource_images/'), self.file_hash ).to_s
  end
  def cdn_uri
    ResizedImagesCachePathVirtual.pathname.join( LiquidFilter::ResizeImg.hash_string_to_path( self.file_hash ).to_s ).to_s + '.' + self.file_extension
  end
	def only_mime_types
		%w(image/jpeg image/gif image/png image/x-png image/svg+xml image/tiff)
	end

	VALID_SUBCLASSES = %w(ShowStillImage ShowSplashImage EpisodeStillImage).freeze

	def self.is_valid_subclass_name?( n )
		VALID_SUBCLASSES.include?(n)
	end

	def file_size_in_words
		if self.file_size > 1000000000
			pluralize( self.file_size.to_f/1000000000.0, 'gigabyte' ) + ' (GB)'
		elsif self.file_size > 1000000
			pluralize( self.file_size.to_f/1000000.0, 'megabyte' ) + ' (MB)'
		elsif self.file_size > 1000
			pluralize( self.file_size.to_f/1000.0, 'kilobyte' ) + ' (KB)'
		else
			pluralize( self.file_size, 'byte' ) + ' (B)'
		end
	end
	

	validates_uniqueness_of :file_hash
	validates_presence_of :alt_text
	validates_length_of :alt_text, :in => 2..255


end
