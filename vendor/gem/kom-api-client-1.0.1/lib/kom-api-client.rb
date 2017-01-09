require 'net/http'
require 'net/https'
require 'json'
require 'openssl'


module KomApi


  class ForbiddenError < StandardError
    attr_reader :request, :response
    def initialize( request, response )
      @request = request
      @response = response
      if RUBY_VERSION.eql?('1.8.7')
        super("Permission denied for request. Ensure you have: '#{request.method}' permission on uri: '#{request.path}'; Server said: " + response.body)
      else
        super("Permission denied for request. Ensure you have: '#{request.method}' permission on uri: '#{request.uri}'; Server said: " + response.body)
      end
    end
  end
  class SendError < StandardError
    attr_reader :http_response, :response_json
    def initialize( http_response_p )
      @http_response = http_response_p
      begin
      @response_json = JSON.load(http_response.body)
      rescue
        # do nothing, just skip if problem
        @response_json = {}
      end
      super('HTTP, Client, or Server Error: ' + http_response.code.to_s + ': ' + http_response.body)
    end
  end
  class ResourceNotFound < SendError
  end # ResourceNotFound

  class Client
    GEM_VERSION = '1.0.1'


    attr_reader :key_uuid, :key_secret, :base_uri, :last_errors

    CONTENT_TYPES = {'json' => 'application/json'}.freeze

    AUTH_TYPE_NAME = 'ApiKey'

    VERSION = 'v1'

    def initialize( base_uri, key_uuid, key_secret )
      @base_uri = base_uri
      @key_uuid = key_uuid
      @key_secret = key_secret
      @content_type = nil
      clear_errors
    end

    def clear_errors
      @last_errors = []
    end

    def content_type(uri)
      # json is default
      ex = 'json'
      ext = File.extname(uri.path)[1..-1]
      ex = ext if !ext.nil? and !ext.empty?

      CONTENT_TYPES[ex]
    end

    def signature( request, params )
      plain = request.method.upcase + "\n"
      if %w(POST DELETE PUT).include?(request.method.upcase)
        md5 = OpenSSL::Digest::MD5.hexdigest(request.body || '')
        plain << md5
        request['CONTENT-MD5'] = md5
      end
      plain << "\n"
      plain << CONTENT_TYPES['json'] + "\n"
      if %w(POST DELETE PUT).include?(request.method.upcase) # Wed, 22 Dec 2004 11:34:47 GMT
        date = Time.now.utc.strftime( '%a, %-d %b %Y %H:%M:%S GMT' )
        request['DATE'] = date
        plain << date
      end
      plain << "\n"
      if RUBY_VERSION.eql?('1.8.7')
        plain << uri_path_with_params(request.method.upcase, request.path, params)
      else
        plain << uri_path_with_params(request.method.upcase, request.uri.path, params)
      end
      plain << "\n"

      if false  # debugging
        puts 'client:'
        puts plain
        puts '==='
      end

      OpenSSL::HMAC.hexdigest( OpenSSL::Digest::SHA512.new, @key_secret, plain )
    end
    private :signature

    def uri_path_with_params(verb, uri_path, p)
      plain = uri_path
      plain << '?' + URI.encode_www_form(ordered_and_flattened_params(p)) if !verb.eql?('POST') and !p.empty?
      plain
    end
    private :uri_path_with_params

    def ordered_and_flattened_params( p )
      p.keys.sort.map{|k| [k,p[k]]}
    end
    private :ordered_and_flattened_params


    def execute_request(verb, uri_path, pparams = {})
      clear_errors
      params = {}
      pparams.each_pair do |k,v|
        params[k] = v if !v.nil?
      end
      uri_path = '/' + VERSION + uri_path
      http = Net::HTTP.new( @base_uri.host, @base_uri.port || ( @base_uri.scheme.eql?('http') ? 80 : 443 ) )
      http.use_ssl = true if @base_uri.scheme.eql?('https')
      http.start do |http|
        # enable SSL if we're using it, which we should be
        u = @base_uri.dup
        u.path = uri_path
        request = case verb
                    when 'GET'
                      u.query = URI.encode_www_form(ordered_and_flattened_params(params)) unless params.empty?
                      if RUBY_VERSION.eql?('1.8.7')
                        Net::HTTP::Get.new u.path
                      else
                        Net::HTTP::Get.new u
                      end
                    when 'POST'
                      if RUBY_VERSION.eql?('1.8.7')
                        req = Net::HTTP::Post.new u.path
                      else
                        req = Net::HTTP::Post.new u
                      end
                      req.body = JSON.dump(params)
                      req
                    when 'DELETE'
                      u.query = URI.encode_www_form(ordered_and_flattened_params(params)) unless params.empty?
                      if RUBY_VERSION.eql?('1.8.7')
                        Net::HTTP::Delete.new u.path
                      else
                        Net::HTTP::Delete.new u
                      end
                      r
                    when 'PUT'
                      if RUBY_VERSION.eql?('1.8.7')
                        req = Net::HTTP::Put.new u.path
                      else
                        req = Net::HTTP::Put.new u
                      end

                      if params.is_a?(String)
                        req.body = params
                      else
                        req.body = JSON.dump(params)
                      end
                      req
                    else
                      raise NotImplementedError.new 'Only GET, POST, and DELETE have been implemented thus far'
                  end

        request['Content-Type'] = 'application/json'
        request['Authorization'] = AUTH_TYPE_NAME + ' ' + @key_uuid + ':' + signature(request,params)

        response = http.request request

        unless response.code.start_with?('2')
          case response.code
            when '404'
              raise ResourceNotFound.new( response )
            when '403'
              raise ForbiddenError.new( request, response )
            when '400'
              @last_errors << JSON.load( response.body )['errors']
              raise SendError.new( response )
            else
              raise SendError.new( response )
          end
        end
        response
      end
    end
    #private :execute_request



    def version
      JSON.load(execute_request('GET','/key/version').body)
    end

    def create_key( enabled = true, name = nil, comment = nil )
      ret = execute_request('POST', '/key', { :enabled => (enabled ? 't' : 'f'), :name => name, :comment => comment } ).body
      JSON.load(ret)
    end

    def create_role( name = nil, comment = nil )
      ret = execute_request('POST', '/key/role', { :name => name, :comment => comment } ).body
      JSON.load(ret)['uuid']
    end

    def remove_role( role_uuid )
      ret = execute_request('DELETE', "/key/role/#{role_uuid}" )
      ret.code.eql?('200')
    end

    def roles
      ret = execute_request('GET', '/key/roles' ).body
      JSON.load(ret)['roles']
    end

    def create_permission( role_uuid, method, uri_path = '/', allow = true )
      ret = execute_request('POST', '/key/permission', { :role_uuid => role_uuid, :method => method, :uri_path => uri_path, :allow => (allow ? 't' : 'f') } ).body
      JSON.load(ret)['uuid']
    end

    def link_key_to_role( key_uuid, role_uuid )
      ret = execute_request('POST', '/key/role/link_key.json', { :role_uuid => role_uuid, :key_uuid => key_uuid } ).body
      JSON.load(ret)
    end

    def unlink_key_from_role( key_uuid, role_uuid )
      ret = execute_request('POST', '/key/role/unlink_key.json', { :role_uuid => role_uuid, :key_uuid => key_uuid } ).body
      JSON.load(ret)
    end

    def roles_for_key_uuid( key_uuid )
      ret = execute_request('GET', "/key/roles/#{key_uuid}" ).body
      JSON.load(ret)['roles']
    end

    def permissions_for_role( role_uuid )
      ret = execute_request('GET', "/key/permission/for_role/#{role_uuid}" ).body
      JSON.load(ret)['permissions']
    end

    def remove_permission( permission_uuid )
      ret = execute_request('DELETE', "/key/permission/#{permission_uuid}" )
      ret.code.eql?('200')
    end

    def user_create( options )
      ret = execute_request('POST', '/user', options ).body
      JSON.load(ret)
    end

    def get_user_by_uuid( user_uuid )
      ret = execute_request('GET', "/user/show/#{user_uuid}" ).body
      JSON.load(ret)['user']
    end

    def get_user_by_email( email )
      ret = execute_request('GET', "/user/show/by_email", { :email => email } ).body
      JSON.load(ret)['user']
    end

    def user_authenticate_by_uuid( uuid, password )
      ret = execute_request('POST', "/user/authenticate/uuid/#{uuid}", {:password => password}).body
      JSON.load(ret)['authenticated']
    end

    def user_authenticate_by_email( email, password )
      ret = execute_request('POST', '/user/authenticate/email', {:email => email, :password => password}).body
      JSON.load(ret)['authenticated']
    end

    def user_password_update_by_uuid( user_uuid, new_password )
      ret = execute_request('POST', "/user/password/#{user_uuid}", {:password => new_password}).body
      JSON.load(ret)['success']
    end

    def user_password_update_by_email( email, new_password )
      ret = execute_request('POST', '/user/password/by_email', {:email => email, :password => new_password}).body
      JSON.load(ret)['success']
    end

    def user_confirmation_code_create( user_uuid, email )
      ret = execute_request('POST', '/user/email_confirmation', {:user_uuid => user_uuid, :email => email}).body
      JSON.load(ret)['code']
    end

    def user_email_confirmed?( user_uuid )
      ret = execute_request('GET', "/user/email_confirmation/status/#{user_uuid}").body
      JSON.load(ret)['confirmed?']
    end

    def user_confirmation_code_verify( code )
      ret = execute_request('POST', "/user/email_confirmation/verify/#{code}").body
      JSON.load(ret)
    end

    def user_password_reset_request_create( user_uuid )
      ret = execute_request('POST', "/user/password_reset/#{user_uuid}").body
      JSON.load(ret)['code']
    end

    def user_password_reset_request_verify( code )
      ret = execute_request('POST', "/user/password_reset/verify/#{code}").body
      JSON.load(ret)
    end

    def user_set( user_uuid, key, value )
      ret = execute_request('PUT', "/user/kvo/#{user_uuid}/#{key}", {:value => value, :override => true}).body
      JSON.load(ret)['success']
    end

    def user_set_if_not_present( user_uuid, key, value )
      begin
        ret = execute_request('PUT', "/user/kvo/#{user_uuid}/#{key}", {:value => value, :override => false}).body
        JSON.load(ret)['success']
      rescue KomApi::SendError => e
        if e.response_json['errors'].has_key?('key') and e.response_json['errors']['key'].include?('already exists')
          return false
        else
          raise e # pass on unknown error
        end
      end
    end

    def user_get( user_uuid, key = nil )
      if key.nil?
        ret = execute_request('GET', "/user/kvo/#{user_uuid}").body
      else
        ret = execute_request('GET', "/user/kvo/#{user_uuid}/#{key}").body
      end
      JSON.load(ret)
    end

    def user_unset( user_uuid, key )
      ret = execute_request('DELETE', "/user/kvo/#{user_uuid}/#{key}").body
      JSON.load(ret)
    end

    def user_key_values( user_uuid )
      ret = execute_request('GET', "/user/kvo/#{user_uuid}").body
      JSON.load(ret)
    end



    def paypal_credit_card_store( user_uuid, vault_uuid, last_four_account, name_on_card, expiration, protected_from_delete = false )
      ret = execute_request('PUT', "/paypal_credit_card/#{vault_uuid}", {:user_uuid => user_uuid, :expiration => expiration, :protected_from_delete => protected_from_delete, :name_on_card => name_on_card, :last_four_account => last_four_account })
      JSON.load(ret.body)['success']
    end
    def paypal_credit_cards_for_user_uuid( user_uuid )
      ret = execute_request('GET', "/paypal_credit_card/all/#{user_uuid}").body
      JSON.load(ret)['paypal_credit_cards']
    end
    def paypal_credit_card_remove( vault_uuid )
      ret = execute_request('DELETE', "/paypal_credit_card/#{vault_uuid}")
      JSON.load(ret.body)['success']
    end
    def paypal_credit_card_touch_last_used_at( vault_uuid )
      ret = execute_request('POST', "/paypal_credit_card/touch_last_used_at/#{vault_uuid}")
      JSON.load(ret.body)['success']
    end




    def address_create( user_uuid, address, tags = nil )
      qv = {:user_uuid => user_uuid}
      qv.merge!(:tags => self.class.format_tags_for_query(tags)) unless tags.nil?
      ret = execute_request('POST', '/address', qv.merge(address))
      JSON.load(ret.body)
    end

    def addresses_for_user_uuid( user_uuid )
      ret = execute_request('GET', "/address/all_for_user_uuid/#{user_uuid}").body
      JSON.load(ret)['addresses']
    end

    def addresses_for_user_uuid_with_tags( user_uuid, tags )
      ret = execute_request('GET', "/address/all_for_user_uuid/#{user_uuid}", {:tags => self.class.format_tags_for_query(tags) }).body
      JSON.load(ret)['addresses']
    end

    def address_replace_tags( address_uuid, tags )
      ret = execute_request('PUT', "/address/tags/#{address_uuid}", {:tags => self.class.format_tags_for_query(tags) }).body
      JSON.load(ret)['success']
    end

    def address_destroy( address_uuid )
      ret = execute_request('DELETE', "/address/#{address_uuid}").body
      JSON.load(ret)['success']
    end

    def self.format_tags_for_query( array_of_tags )
      array_of_tags.map{|x| x.strip}.join(',')
    end



    def membership_level_for_user_uuid( user_uuid )
      ret = execute_request('GET', "/membership/#{user_uuid}").body
      JSON.load(ret)['membership']
    end

    def membership_set( user_uuid, level, expires_at = nil )
      ret = execute_request('PUT', "/membership/#{user_uuid}", {:level => level, :expires_at => (expires_at.nil? ? nil : expires_at.to_i) }).body
      JSON.load(ret)['success']
    end

    def membership_expire_for_user_uuid( user_uuid )
      ret = execute_request('POST', "/membership/expire/#{user_uuid}").body
      JSON.load(ret)['success']
    end



    def set_username( user_uuid, username )
      ret = execute_request('POST', "/user/username/#{user_uuid}", :username => username).body
      JSON.load(ret)['success']
    end

    def get_username( user_uuid )
      ret = execute_request('GET', "/user/username/#{user_uuid}").body
      r = JSON.load(ret)
      if r
        r['username']
      end
    end


  end # Client

end # KomApi


