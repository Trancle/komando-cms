require 'net/http'
require 'timeout'
require 'rexml/document'
class CwAuthenticationKimsClub < CwAuthentication
	include CW::ActsAs::Cacheable

	attr_reader :last_parsed_xml

	def is_authenticated?
		@last_parsed_xml = query_cache 
		self.class.is_authenticated?( @last_parsed_xml, @credentials[:username] )
	end

	def self.is_authenticated?( xml, username )
		extract( xml, 'loginstatus', username ).eql?'success'
	end

	def uid
		@last_parsed_xml = query_cache 
		theid = self.class.extract_uid( @last_parsed_xml, @credentials[:username] )
		if theid.to_i.eql?0
			# this should NOT happen
			raise ArgumentError.new( 'The UID returned was 0, which is invalid for Kim\'s Club' )
		else
			theid
		end
	end

	def username
		@last_parsed_xml = query_cache 
		self.class.extract_username( @last_parsed_xml, @credentials[:username] )
	end

	def email
		@last_parsed_xml = query_cache 
		self.class.extract_email( @last_parsed_xml, @credentials[:username] )
	end

	def self.extract_uid( xml, username )
		extract( xml, 'uid', username )
	end

	def self.extract_username( xml, username )
		extract( xml, 'screenname', username )
	end

	def self.extract_email( xml, username )
		extract( xml, 'email', username )
	end

	def self.extract( xml, fieldname, username )
		u = xml.find{|f| f['email'].eql?( username ) }
		unless u.nil?
			return u[fieldname] if !u.nil? and u.key?(fieldname)
		end
		return nil
	end

	def query
		@response_xml_from_server = self.class.send_request_and_get_response( self, @credentials )
		self.class.interpret_response_xml( @response_xml_from_server )
	end
	acts_as_cacheable_cache_method( :query )

	def self.send_request_and_get_response( s, credentials )
		if CwAuthenticationKimsClubConfig.use_development_authn?
			return CwAuthenticationKimsClub::SAMPLEXML
		else
			begin
				Timeout::timeout(30) do
					res = Net::HTTP.post_form( URI.parse( s.class.uri ), { s.class.username_field_name => credentials[:username], s.class.password_field_name => credentials[:password] } )
					res.body
				end
			rescue Timeout::Error => e
				# return nothing
				# Timedout
				''
			end
		end
	end

	SAMPLEXML = <<EODOC
<?xml version="1.0" encoding="UTF-8"?>
<authenticationresponse>
	<user>
		<loginstatus>success</loginstatus>
		<isadmin>true</isadmin><!-- always false if login failed-->
		<uid>5</uid>
		<screenname>WojnoTest</screenname>
		<email>christopher@wojno.com</email>
	</user>
	<user>
		<loginstatus>success</loginstatus>
		<isadmin>false</isadmin><!-- always false if login failed-->
		<uid>6</uid>
		<screenname>normal</screenname>
		<email>normal</email>
	</user>
	<user>
		<loginstatus>success</loginstatus>
		<isadmin>false</isadmin><!-- always false if login failed-->
		<uid></uid>
		<screenname></screenname>
		<email>fail</email>
	</user>
</authenticationresponse>
EODOC

	def self.interpret_response_xml( resp )
		doc = REXML::Document.new( resp )
		users = []
		doc.elements.each('authenticationresponse/user') { |user| users << {}; user.elements.each('*') { |attrs| users.last[attrs.name] = attrs.text } }
		users
	end

	def self.uri
		CwAuthenticationKimsClubConfig.uri
	end
	def self.username_field_name
		CwAuthenticationKimsClubConfig.username_field_name
	end
	def self.password_field_name
		CwAuthenticationKimsClubConfig.password_field_name
	end

	def problem_diagnostic_string
		@response_xml_from_server.to_s
	end

end
