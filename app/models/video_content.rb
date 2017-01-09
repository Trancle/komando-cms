class VideoContent < ActiveRecord::Base
	include CW::ManagedFileResource::ModelPrivateFile
	def self.base_path; RAILS_ROOT + '/private/videos/'; end

	def self.mfrn_klass_name; 'VideoContentName'; end
	include CW::ManagedFileResourceName::MfrModel
	include CW::ActsAs::Cacheable

	belongs_to :video_content_name, :foreign_key => 'pretty_name_id'
	belongs_to :video_content_hosting_provider
	has_many :ad_insertion_locations, :class_name => 'EpisodePartAdInsertionLocation', :foreign_key => 'episode_part_id', :order => EpisodePartAdInsertionLocation.find_order_options[:order]

	validates_format_of :colonized_length, :allow_nil => true, :with => /\A((\d+:)?[0-5]?[0-9]:)?[0-5]?[0-9](.\d+)?\Z/i, :if => :should_validate_colonized_length?
# Ensure that an "uploader" is specified for record keeping
	validates_each 'uploader_user_id' do |record, attr, value|
		record.errors.add attr, 'does not exist.' unless User.exists?( value )
	end
# Ensure that the parent exists
	validates_each 'pretty_name_id' do |record, attr, value|
		record.errors.add attr, 'does not exist.' unless VideoContentName.exists?( value )
	end



	# Allows the time conversions to occur
	include ActionView::Helpers::DateHelper
	include ActionView::Helpers::TextHelper


	def short_name
		raise NotImplementedError.new
	end


	def only_mime_types
		%w(video/mpeg video/mp4 video/x-flv)
	end

	def friendly_type_name
		self.class.name.sub('VideoContent','').underscore.humanize
	end

	def self.friendly_type_description
		raise NotImplementedError.new( "Subclasses of #{self.class.name} must override 'friendly_type_description'" )
	end

	VALID_SUBCLASSES = %w(VideoContentEmbeddedOnDemand VideoContentHostedLive VideoContentHostedOnDemand).freeze
	def self.is_valid_subclass?( v )
		VALID_SUBCLASSES.include?(v)
	end

	def self.is_valid_sub_subclass?( v )
		sc = VALID_SUBCLASSES.find{|s| v.start_with?(s) }
		unless sc.nil?
			sc.constantize.is_valid_subclass?( v )
		else
			return false
		end
	end

	def self.subclass_from_sub_subclass( subsubclass )
		VALID_SUBCLASSES.find(nil) do |sc|
			subsubclass.class.name.start_with?( sc )
		end
	end

	def self.subclass_name( subclass )
		subsub = sub_subclass_name(subclass)
		t = subclass.class.name[self.name.length..-1]
		unless subsub.nil?
			t[0..(-1*(subsub.length + 1))]
		else
			t
		end
	end

	def self.sub_subclass_name( subsubclass )
		scfssc = subclass_from_sub_subclass( subsubclass )
		raise "There is no subclass for #{subsubclass.class.name}" if scfssc.nil?
		subsubclass.class.name[scfssc.length..-1]
	end

	def is_url?
		begin
			URI.parse( self.type_information )
			return true
		rescue URI::InvalidURIError => s
			return false
		end
	end

	def length_in_words
		if self.length_in_seconds.eql?0.0
			'0 seconds'
		elsif (self.length_in_seconds%3600.0).eql?(0.0)
			pluralize( (self.length_in_seconds/3600).to_i, 'hour' )
		elsif (self.length_in_seconds%60.0).eql?(0.0)
			pluralize( (self.length_in_seconds/60).to_i, 'minute' )
		else
			distance_of_time_in_words( 0, length_in_seconds, true )
		end
	end

	def self.colonized_length( d )
		parts = d.to_s.split(':')
		total = 0.0
		# hours
		if parts.size.eql?( 3 )
			v = parts.shift.to_f
			total += v.to_f*3600.0
		end
		# minutes
		if parts.size.eql?( 2 )
			v = parts.shift.to_f
# If >= 60 minutes, don't care
			total += v*60.0
		end
		# seconds
		if parts.size.eql?( 1 )
			# must be seconds
			v = parts.shift.to_f
# if >= 60 seconds, don't care
			total += v
		end

		total
	end

	def self.colonized_length_to_s( seconds )
		ret = []
		h = 0
		m = 0
		h = (seconds/3600.0).floor
		unless h.eql?0
			ret << h.to_s
		end
		m = ((seconds - (3600*h).to_f)/60.0).floor
		unless m.eql?0
			ret << ( ( m < 10.0 and !h.eql?0 ) ? ( '0' + m.to_s ) : ( m.to_s ) )
		else
			ret << '00' unless ret.empty?
		end
		s = ( seconds % 60.0 ).to_i
		ret << ( ( s < 10 and ( !h.eql?0 or !m.eql?0 ) ) ? ( '0' + s.to_s ) : ( s.to_s ) )

		s_s = seconds.to_s
		if s_s.index('.')
			ret[ret.size-1] += '.' + s_s[s_s.index('.')+1..-1]
		else
			ret[ret.size-1] += '.0'
		end

		ret.join(':')
	end

	def colonized_length=( d )
		@colonized_length = d
		self.length_in_seconds = self.class.colonized_length( d )
	end

	def colonized_length
		@colonized_length || self.class.colonized_length_to_s( self.length_in_seconds )
	end

	def validate
		begin
			VideoContentName.find( self.pretty_name_id ).nil?
		rescue ActiveRecord::RecordNotFound => s
			self.errors.add( :pretty_name_id, 'does not exist' )
		end
	end

	def safe_to_delete?( t = Time.now.utc )
		# if the file is too new, don't delete it
		return false if self.created_at > t - Setting['vms-protected-new-video-deletion-grace-period-days'].value_typed.days

		# Check the schedules, see if this file's name has any linkage to ads/episodes
		self.video_content_name.safe_to_delete_assuming_videos_safe_to_delete?( t )
	end

	def used_in_episode?
		!EpisodePart.find(:first, :conditions => ['video_content_name_id = ?',self.video_content_name.id]).nil?
	end

	def count_episodes
		EpisodePart.count(:conditions => ['video_content_name_id = ?',self.video_content_name.id])
	end

	def episodes( limit = 10 )
		EpisodePart.find( :all, :limit => limit, :conditions => ['video_content_name_id = ?', self.pretty_name] ).collect{|e| e.episode}
	end



# video_content_name_id is deprecated and is never set or read: use pretty_name_id ALWAYS
	def video_content_name_id
		raise 'Don\'t use VideoContent.video_content_name_id'
	end
	def video_content_name_id=( v )
		raise 'Don\'t use VideoContent.video_content_name_id='
	end


	def should_validate_colonized_length?
		@should_validate_colonized_length
	end

	def set_should_validate_colonized_length( v = true )
		@should_validate_colonized_length = v
	end


	public

# not all subclasses require a hosting provider (embedded do not), but hosted do
	def validates_hosting_provider_id( record, attr, value )
		unless VideoContentHostingProvider.exists?( value )
			record.errors.add attr, 'does not exist.'
		else
			provider = VideoContentHostingProvider.find( value )
			record.errors.add attr, 'is not enabled.' unless provider.enable
			record.errors.add attr, 'is deprecated.' if provider.deprecated
		end
	end


	# default is to always be able to publish
	def can_publish?
		true
	end



	def exact_aspect_ratio
		return nil if self.height.nil? or self.width.nil? or self.height.eql?0
		return 0 if self.width.eql?0
		return self.width.to_f/self.height.to_f
	end

	COMMON_ASPECT_RATIOS = { 1.78 => '16:9', 1.33 => '4:3', 1.5 => '3:2' }

	def estimate_aspect_ratio
		r = exact_aspect_ratio
		return 'N/A' if r.nil?
		COMMON_ASPECT_RATIOS.each_pair do |a,v|
			return v if r - 0.01 < a and a < r + 0.01
		end
		return ( '%.2f' % r ) + ':1' # last-ditch guess
	end

end
