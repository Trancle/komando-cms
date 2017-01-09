module LiquidFilter
  module Hmac

    # {{ 'sign-this' | hmac_md5: 'secret-key' }}
    def hmac_md5( data, key )
      OpenSSL::HMAC.hexdigest( OpenSSL::Digest::MD5.new, key, data )
    end


    def hmac_sha1( data, key )
      OpenSSL::HMAC.hexdigest( OpenSSL::Digest::SHA1.new, key, data )
    end

  end
end
Liquid::Template.register_filter(LiquidFilter::Hmac)