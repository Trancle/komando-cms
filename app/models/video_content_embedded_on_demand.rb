require 'rexml/document'
class VideoContentEmbeddedOnDemand < VideoContent
	include FreeFormModelAttributeModel

	composed_of :embed_attrs, :class_name => "FreeFormModelAttribute", :mapping => %w(type_information to_composition)
	validates_length_of :type_information, :in => 3..4000

	def self.friendly_type_description
<<ENDOFDOC
<p>Video content we probably don't produce because this content is hosted at other websites. We're embedding via a URL or explicity embed text.</p>
ENDOFDOC
	end

	before_validation :commit_embed_attrs

	private
		def commit_embed_attrs
			self.embed_attrs = self.embed_attrs.dup
		end
	public



	VALID_EMBEDTYPES = %w(HTML YouTube Vimeo CNET CBS).freeze
	def self.supported_embed_services
		VALID_EMBEDTYPES.reject{|t| t.eql?('HTML') }
	end
	def self.is_valid_subclass?( v )
		VALID_EMBEDTYPES.collect{|e| self.name + e }.include?( v )
	end

	def embed_type
		# Default value: override in descendents
		'HTML'
	end






# LEGACY FROM BEFORE: 6fb3d0be92c69b5949feca71ba8938ec9ae883d7

	# For versions prior to 6fb3d0be92c69b5949feca71ba8938ec9ae883d7 (Mar 24, 2011)
	def is_non_yaml_version?
		!YAML.load(self.type_information).is_a?(Hash)
	end

	def legacy_embed_type
		if self.type_information.index( "youtube+http://" )
		'you_tube'
		elsif self.type_information.index( "vimeo+http://" )
		'vimeo'
		elsif self.type_information.index( "cnn+http://" )
		'cnn'
		else
		'html'
		end
	end

	def legacy_embed_code_parse_parameters( uri )
		stripbefore = '+http://'
		video_id_with_params = uri[(uri.index(stripbefore)+stripbefore.size)..-1]
		param_start = video_id_with_params.index('?')
		video_id = nil
		parms = ''
		options = legacy_embed_default_options
		if param_start.nil?
			video_id = video_id_with_params
		else
			video_id = video_id_with_params[0..param_start-1]
			parms = video_id_with_params.sub(video_id + '?','')
			parms = parms.split('&')
			parms_h = {}
			parms.each do |p|
				keypair = p.split('=')
				parms_h[keypair[0].to_sym] = keypair[1]
			end
		options[:auto_play] = parms_h[:auto_play].eql?'t' if parms_h[:auto_play]
		options[:show_related_videos] = parms_h[:show_related_videos].eql?'t' if parms_h[:show_related_videos]
		options[:show_video_information] = parms_h[:show_video_information].eql?'t' if parms_h[:show_video_information]
		options[:start_offset] = parms_h[:start_offset].to_i if parms_h[:start_offset]
		end

		return video_id, options
	end
	def legacy_embed_default_options( options = {} )
		options[:width] = '620px' if options[:width].nil?
		options[:height] = '350px' if options[:height].nil?
		options[:auto_play] = false if options[:auto_play].nil?
		options[:show_related_videos] = false if options[:show_related_videos].nil?
		options[:show_video_information] = false if options[:show_video_information].nil?
		options[:start_offset] = 0 if options[:start_offset].nil?
		options
	end

end
