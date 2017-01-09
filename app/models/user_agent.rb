# User Agent
# Encapsulates the User-agent string. Is a componentized version for working with user-agents
class UserAgent
	attr_reader :ua

	BROWSER_BASE = [:mozilla,:gecko,:webkit].freeze
	# Order of most used as of 2011-04-05
	BROWSERS = [:msie,:firefox,:safari,:chrome,:opera,:konqueror].freeze
	OSES = [:darwin,:windows,:linux,:bsd,:ios,:android].freeze

	def initialize( user_agent )
		@ua = user_agent
	end

	def browser
		BROWSERS.find{|b| self.send( b.to_s + "?" ) }
	end

	def os
		OSES.find{|b| self.send( b.to_s + "?" ) }
	end

	def iphone?
		@ua.include?("iPhone")
	end

	def ipod?
		@ua.include?("iPod")
	end

	def ios?
		iphone? or ipod?
	end

	def safari?
		@ua.include?("Safari")
	end

	def chrome?
		@ua.include?("Chrome")
	end

	def firefox?
		@ua.include?("Firefox")
	end

	def msie?
		@ua.include?("MSIE")
	end

	alias :ie? :msie?

	def opera?
		@ua.include?("Opera")
	end

	def konqueror?
		@ua.include?("Konqueror")
	end


	def mac?
		@ua.include?("Macintosh")
	end

	def windows?
		@ua.include?("Windows")
	end

	def linux?
		@ua.include?("Linux")
	end

	def bsd?
		free_bsd? or net_bsd? or open_bsd?
	end

	def net_bsd?
		@ua.include?("NetBSD")
	end

	def free_bsd?
		@ua.include?("FreeBSD")
	end

	def open_bsd?
		@ua.include?("OpenBSD")
	end

	def android?
		@ua.include?("Android")
	end

	def blackberry?
		@ua.include?("Blackberry")
	end

# Mobile?
# Reports if the browser is likely to be on a mobile platform
# return true if browser is likely running on a mobile platform, false if it isn't or is unknown
	def mobile?
		android? or ios? or blackberry?
	end

# Version
# Parse the version of the browser based on the browser that is reported
	def browser_version
		# get the browser
		b = self.browser
		return nil if b.nil?
		self.send( 'version_' + b.to_s )
	end

# Get's the browser version for MSIE
	def version_msie
		
	end

	def version_chrome
		# Chrome's UA string is like:
		# Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US) AppleWebKit/534.16 (KHTML, like Gecko) Chrome/10.0.648.133 Safari/534.16
		r = /Chrome\/(\S+)/
		v = r.match(self.ua)
		unless v.size.eql?(0)
			ComponentizedProductVersion.new(v[1])
		else
			nil
		end
	end

	def version_safari
		# Safari's UA string is like:
		# Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_7; en-us) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.4 Safari/533.20.27

		r = /Version\/(\S+).*Safari/
		v = r.match(self.ua)
		unless v.size.eql?(0)
			ComponentizedProductVersion.new(v[1])
		else
			nil
		end
	end

	def version_msie
		# IE UA string is like:
		# Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)

		r = /MSIE ([^;]+);/
		v = r.match(self.ua)
		unless v.size.eql?(0)
			ComponentizedProductVersion.new(v[1])
		else
			nil
		end
	end
	alias :version_ie :version_msie

# Browser
# report if browser is indicated by UA string
	def browser?(b)
		return nil unless BROWSERS.include?(b)
		# test for that browser, cheat using meta-programming
		send(b.to_s + "?")
	end


end
