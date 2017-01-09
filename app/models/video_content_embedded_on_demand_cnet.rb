class VideoContentEmbeddedOnDemandCNET < VideoContentEmbeddedOnDemand
	ffma_create_attribute 'embed_attrs', 'video_id', :string

	def short_name
		'CNET embedded on demand ' + video_id
	end

	def embed_type
		'CNET'
	end

	validates_presence_of :video_id
	validates_length_of :video_id, :in => 4..32
	validates_numericality_of :video_id, :greater_than => 0, :only_integer => true

end
