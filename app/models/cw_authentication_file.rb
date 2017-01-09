class CwAuthenticationFile < CwAuthentication

	attr_reader :errors
	def is_authenticated?
		#load the file
		begin
			unless credential_file_exists?
				add_error "Credential file: #{path_to_credential_file} does not exist. Please create it and populate it with YAML credentials."
			else
					auth_credentials = YAML::load_file( path_to_credential_file.to_s )
					@username = credentials[:username]
					creds = auth_credentials[@username]
					return false if creds.nil?
					@uid = creds['uid']
					@email = creds['email']
					return creds['password'].eql?(credentials[:password])
			end
		rescue StandardError => s
			add_error s.to_s
			raise s
			return false
		end
	end
	def email; @email; end
	def uid; @uid; end
	def username; @username; end

	def credential_file_exists?
		File.exists?( path_to_credential_file.to_s )
	end

	def path_to_credential_file
		Pathname.new(RAILS_ROOT) + self.class.path_to_credential_file_from_rails_root
	end

	def self.path_to_credential_file_from_rails_root
		if defined?(CwAuthenticationFileConfig).eql?('constant') and CwAuthenticationFileConfig.class.eql?(Class)
			return CwAuthenticationFileConfig.path_to_credential_file_from_rails_root
		else
			return 'config/auth.yml'
		end
	end

# YML FILE Stucture
# The YML file is simple and contains nothing but primitive objects
#--- 
#admin: 
#  enabled: false
#  admin: true
#  password: adminadmin
#  email: chris@wojnosystems.com
#admin2: 
#  enabled: false
#  admin: true
#  password: adminadmin
#  email: chris@wojnosystems.com
#

end
