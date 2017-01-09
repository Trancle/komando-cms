class VideoContentEmbeddedOnDemandHTML < VideoContentEmbeddedOnDemand

	ffma_create_attribute 'embed_attrs', 'raw', :string
	def short_name
		'Raw HTML'
	end

	def embed_type
		'HTML'
	end

end
