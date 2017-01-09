class VideoContentHostingProviderOnDemandScpHttp < VideoContentHostingProviderOnDemand

	ffma_create_attribute 'configuration', 'scp_username', :string
	ffma_create_attribute 'configuration', 'scp_private_key', :string
	ffma_create_attribute 'configuration', 'scp_options', :string
	ffma_create_attribute 'configuration', 'scp_host', :string
	ffma_create_attribute 'configuration', 'scp_port', :integer, 22
	ffma_create_attribute 'configuration', 'scp_options', :integer, 22

	def content_model_name
		'VideoContentHostedOnDemandScpHttp'
	end

end
