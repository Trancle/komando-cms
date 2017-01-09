require 'net/http'
require 'timeout'
require 'rexml/document'
class CwAuthorizationKimsClub < CwAuthorizationStatus

	attr_reader :last_parsed_xml
	attr_accessor :authentication_mechanism

	def can_access_backoffice?
		if @authentication_mechanism.nil?
			# no auth mech saved: start from scratch
			r = self.class.send_request_and_get_response( self, @uid )
			@last_parsed_xml = CwAuthenticationKimsClub.interpret_response_xml( r )
			self.class.can_access_backoffice?( @uid )
		else
			# auth mech saved: use that to avoid another request
			@authentication_mechanism.is_authenticated? and self.class.can_access_backoffice?( @authentication_mechanism.last_parsed_xml, @uid )
		end
	end

	def self.can_access_backoffice?( xml, username )
		u = xml.find{|f| f['email'].eql?( username ) }
		unless u.nil?
			return true if !u.nil? and u.key?('isadmin') and u['isadmin'].eql?'true'
		end
		false
	end

	def self.send_request_and_get_response( s, credentials )
		if CwAuthenticationKimsClubConfig.use_development_authn?
			return CwAuthenticationKimsClub::SAMPLEXML
		else
			begin
			Timeout.timeout(30) do
				res = Net::HTTP.post_form( URI.parse( s.class.uri ), { s.class.username_field_name => @uid } )
				res.body
			end
			rescue Timeout::Error => e
				# return nothing
				''
			end
		end
	end

	def self.uri
		CwAuthorizationKimsClubConfig.uri
	end
	def self.username_field_name
		CwAuthorizationKimsClubConfig.username_field_name
	end

	def self.configuration=( c )
		@@configuration = c
	end
	def self.configuration
		@@configuration
	end

end
