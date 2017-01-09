# CwActsAsCacheable
module CW
module ActsAs
module Cacheable

	def self.included(base)
		base.extend(ClassMethods)
	end

	def cacheable_clear_cache( what = :all )
		@cw_acts_as_cacheable_cache = {} unless instance_variable_defined?( :@cw_acts_as_cacheable_cache )
		if what.eql?:all
			# wipes everything
			@cw_acts_as_cacheable_cache = {}
		elsif what.is_a?(Array)
			what.each do |x|
				cacheable_clear_cache( x )
			end
		elsif what.is_a?(Symbol)
			@cw_acts_as_cacheable_cache.delete( what )
		else
			raise NotImplementedError.new( "cacheable_clear_cache only accepts :all, an array of symbols, or a single symbol" )
		end
		true
	end

	def cacheable_cache( symbol_name, &block )
		@cw_acts_as_cacheable_cache = {} unless instance_variable_defined?( :@cw_acts_as_cacheable_cache )
		if @cw_acts_as_cacheable_cache.key?( symbol_name )
			@cw_acts_as_cacheable_cache[symbol_name]
		else
			@cw_acts_as_cacheable_cache[symbol_name] = yield
		end
	end

	module ClassMethods
		# converts an existing method to a cached method. To use the cached version, append _cache to the end of the original call
		def acts_as_cacheable_cache_method( method_symbol )
			self.send( :define_method, (method_symbol.to_s+'_cache').to_sym ) do |*args|
				self.cacheable_cache( method_symbol ) do
					self.send( method_symbol, *args )
				end
			end
		end
	end#ClassMethods

end#Cacheable
end#ActsAs
end#CW
