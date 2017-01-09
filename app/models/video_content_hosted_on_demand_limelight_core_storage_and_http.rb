class VideoContentHostedOnDemandLimelightCoreStorageAndHttp < VideoContentHostedOnDemand

	def after_destroy
		remove_file_from_hosting_provider
	end

	def remove_file_from_hosting_provider
		self.video_content_hosting_provider.video_content_removed( self )
		true
	end

	def short_name
		truncate self.file_hash
	end


# Yes, the flash and http url generators are VERY different... fun

	# Goes in the flash embed code under the param "flashVars" under the variable called "mediaURL"
	def flash_llnw_url( options = {} )
		n = options[:now] || Time.now.utc
		url = (Pathname.new(self.video_content_hosting_provider.flash_uri) + self.video_content_hosting_provider.file_hash_and_extension_to_array( self.file_hash, self.file_extension ).join('/') ).to_s

		if self.video_content_hosting_provider.media_vault_enable
			# Always set the start time to 2 minutes before the current server time
			# This allows for server time drift
			start_time = nil
			end_time = nil
			if self.video_content_hosting_provider.media_vault_security_enforce_time
				start_time = n - self.video_content_hosting_provider.media_vault_security_time_clock_skew_in_seconds
				end_time = n + self.video_content_hosting_provider.media_vault_security_time_clock_skew_in_seconds + self.video_content_hosting_provider.media_vault_security_time_interval_in_seconds
			end
#			ip_restriction = nil
#			if self.video_content_hosting_provider.media_vault_security_enforce_ip
#				ip_restriction = options[:requester_ip_address]
#			end

			self.class.media_vault_core_storage_url_builder( url, self.video_content_hosting_provider.media_vault_secret, end_time, start_time )
#self.class.media_vault_core_storage_url_builder( url, video_content_hosting_provider.media_vault_secret, options[:end_time], options[:start_time], options[:referrer_url], options[:referrer_page], options[:requester_ip_address] )
		else
			url
		end
	end

	##
	# Creates a media vault URL for Flash Hosted On Demand.
	#
	# According to LL_Flash_MediaVault_UG.pdf (as of 2010/03/01 15:44)
	# MD5( SECRET + [Referrer|Page-URL] + URL-Path + URL-Parameters )
	# SECRET is the media_vault_secret (provided by limelight)
	#
	# Time epoc is 1970/01/01 00:00:00 UTC
	# base_url: this is the base url for creating the request. This is how llnw knows which resource to which you are referring.
	#  The base_url contains the scheme://, the host, and a path upto and including the video filename AND extension
	# media_vault_secret: The secret string with which our parameters are hashed
	# end_time: utc time in seconds that the viewer may not view this video after if the video has not already started streaming (if it has, they can get it)
	# start_time: utc time in seconds that viewer may begin watching this video, nil to not have a start_time
	# referrer_url: is the URL to the page from which this video must be embedded, nil to ignore and allow embedding from anywhere
	# page_url: The URL of the page making the request, must match the page upon which this video is embedded (the player), nil to ignore
	# requester_ip_address: ip_address (dotted quad, IPv6 not supported as of 2011/07/11), you must get the viewer's IP address first, then pass hashed to limelight, nil to ignore
	def self.media_vault_core_storage_url_builder( base_url, media_vault_secret, end_time, start_time = nil, requester_ip_address = nil, referrer_url = nil, page_url = nil )
		query_params = {}
		# MD5 always seeded with secret hash
		md5string = ''
		md5string += media_vault_secret

		hashed_query_order = %w(e ip ru pu)
#hashed_query_order = %w(s e ip ru pu)

		# First, let's build the query to be appended to the plain url
		# If start time provided, add it to the query string
#query_params['s'] = start_time.to_i if start_time
		# If end time provided, add it to the query string
		query_params['e'] = end_time.to_i if end_time
		# If ip address provided, add it to the query string
		query_params['ip'] = requester_ip_address if requester_ip_address and !requester_ip_address.empty?

		# We already have the md5secret value, add the referrer URL (if we've configured it to be used)
		if referrer_url
			# We hash the referrer hostname (CONFIRM THIS IN DOCS), but only provide the # of characters in it in clear-text
			md5string += referrer_url
			# add the referrer URL size to the query params:
			query_params['ru'] = referrer_url.length
		end

		# Now add the page url, but only if we're not using referrer protection
		if page_url
			# We hash the page URL, but only provide the # of characters in it in clear-text
			md5string += page_url
			# add the page URL size to the query params:
			query_params['pu'] = referrer_url.length
		end

		# no parameters? nothing to protect, no hashing needed
		if query_params.empty?
			return base_url
		else

			target_path = URI.parse(base_url).path
			md5string += target_path

			# building this hash value list is order dependent. I created an array to capture this order above while still retaining hash flexibility
			tobehashed = md5string + '?' + hashed_query_order.collect{|q| q + '=' + query_params[q].to_s if query_params.has_key?(q) }.compact.join('&')
			thehash = OpenSSL::Digest::MD5.hexdigest( tobehashed )
			query_params['h'] = thehash

			# Here, order does not matter, and includes the magic h param (hash)
			return base_url + '?' + query_params.collect{|k,v| k + "=" + v.to_s }.join('&')
		end
	end



	# Goes in the <video> data field for the src
	def http_llnw_url( options = {} )
		n = options[:now] || Time.now.utc
		url = ( Pathname.new( self.video_content_hosting_provider.http_uri ) + self.video_content_hosting_provider.file_hash_and_extension_to_array( self.file_hash, self.file_extension ).join('/') ).to_s
		if self.video_content_hosting_provider.media_vault_enable
			# Always set the start time to 2 minutes before the current server time
			# This allows for server time drift
			start_time = nil
			end_time = nil
			if self.video_content_hosting_provider.media_vault_security_enforce_time
				start_time = n - self.video_content_hosting_provider.media_vault_security_time_clock_skew_in_seconds
				end_time = n + self.video_content_hosting_provider.media_vault_security_time_clock_skew_in_seconds + self.video_content_hosting_provider.media_vault_security_time_interval_in_seconds
			end
#			ip_restriction = nil
#			if self.video_content_hosting_provider.media_vault_security_enforce_ip
#				ip_restriction = options[:requester_ip_address]
#			end

			self.class.media_vault_http_deliver_url_builder( url, self.video_content_hosting_provider.media_vault_secret, end_time, start_time )
#self.class.media_vault_core_storage_url_builder( url, video_content_hosting_provider.media_vault_secret, options[:end_time], options[:start_time], options[:referrer_url], options[:referrer_page], options[:requester_ip_address] )
		else
			url
		end
	end

	##
	# Creates a media vault URL for HTTP Hosted On Demand.
	#
	# According to Limelight Networks Media Vault for Delivery (as of 2010/03/01 15:44)
	# MD5( SECRET + [Referrer|Page-URL] + URL-Path + URL-Parameters )
	# SECRET is the media_vault_secret (provided by limelight)
	#
	# Time epoc is 1970/01/01 00:00:00 UTC
	# base_url: this is the base url for creating the request. This is how llnw knows which resource to which you are referring.
	#  The base_url contains the scheme://, the host, and a path upto and including the video filename AND extension
	# media_vault_secret: The secret string with which our parameters are hashed
	# end_time: utc time in seconds that the viewer may not view this video after if the video has not already started streaming (if it has, they can get it)
	# start_time: utc time in seconds that viewer may begin watching this video, nil to not have a start_time
	# requester_ip_address: ip_address (dotted quad, IPv6 not supported as of 2011/07/11), you must get the viewer's IP address first, then pass hashed to limelight, nil to ignore
	#
	def self.media_vault_http_deliver_url_builder( base_url, media_vault_secret, end_time, start_time = nil, requester_ip_address = nil )
		query_params = {}
		# MD5 always seeded with secret hash
		md5string = ''
		md5string += media_vault_secret

		hashed_query_order = %w(e ip)

		# First, let's build the query to be appended to the plain url
		# If end time provided, add it to the query string
		query_params['e'] = end_time.to_i if end_time
		# If ip address provided, add it to the query string
		query_params['ip'] = requester_ip_address if requester_ip_address and !requester_ip_address.empty?

		# no parameters? nothing to protect, no hashing needed
		if query_params.empty?
			return base_url
		else

			u = base_url + '?' + hashed_query_order.collect{|q| q + "=" + query_params[q].to_s if query_params.has_key?(q) }.compact.join('&')

			# building this hash value list is order dependent. I created an array to capture this order above while still retaining hash flexibility
			tobehashed = md5string + u
			thehash = OpenSSL::Digest::MD5.hexdigest( tobehashed )
			query_params['h'] = thehash

			# Here, order does not matter, and includes the magic h param (hash)
			return u + "&h=" + thehash
		end
	end







# we need to save and schedule the upload
	def upload_and_save
		if save
			video_content_hosting_provider.video_content_ready_for_upload( self )
			return true
		else
			return false
		end
	end

	def upload_and_save!
		save!
		video_content_hosting_provider.video_content_ready_for_upload( self )
		true
	end






### Check to see if this file is uploaded to the CDN
#
# @return true if it's been published to the CDN, false if not
	def exists_at_cdn?
		video_content_hosting_provider.exists?( self )
	end




	def instance_local_file_path
		( ( ( Pathname.new(RAILS_ROOT) + 'private' ) + 'videos' ) + self.local_path_name ).to_s
	end


end
