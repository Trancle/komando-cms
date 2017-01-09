class CwAuthorizationFile < CwAuthorizationStatus

	def can_access_backoffice?
		begin
			unless credential_file_exists?
				add_error "Credential file for authorization: \"#{path_to_credential_file}\" doens't exist"
			end
			auth_credentials = YAML::load_file( path_to_credential_file )
			creds = auth_credentials[@uid]
			return false if creds.nil?
			u = creds['admin']
			return false if u.nil?
			return u['admin']
		rescue StandardError => s
			add_error s.to_s + "\n" + s.backtrace.join("\n")
		end
	end
	
	def credential_file_exists?
    File.exists?( path_to_credential_file.to_s )
  end
	def path_to_credential_file
		Pathname.new(RAILS_ROOT) + self.class.path_to_credential_file_from_rails_root
	end
	def self.path_to_credential_file_from_rails_root
		if defined?(CwAuthorizationFileConfig).eql?('constant') and CwAuthorizationFileConfig.class.eql?(Class)
			return CwAuthorizationFileConfig.path_to_credential_file_from_rails_root
		else
			return 'config/auth.yml'
		end
	end

end
