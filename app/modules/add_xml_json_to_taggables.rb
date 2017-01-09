module AddXmlJsonToTaggables

	def self.included( base )
		base.extend( ClassMethods )
	end

	def to_xml( count = 20 )
		xml = Builder::XmlMarkup.new
		xml.instruct!
		xml.tags {
			self.tag_cloud_data( count ).each_pair do |k,v|
				xml.tag {
					xml.name( k )
					xml.count( v.to_s )
				}
			end
		}
	end

	def to_json( count = 20 )
		json = '{tags:{'
		json += self.tag_cloud_data( count ).collect do |t,c|
			t + ':' + c.to_s
		end.join(',')
		json += '}}'
	end

	module ClassMethods
		def failed_xml( taggable_add_result )
			xml = Builder::XmlMarkup.new
			xml.instruct!
			xml.fails {
				taggable_add_result[:failed].each do |f|
					xml.name << f.name
				end
			}
		end

		def failed_json( taggable_add_result )
			json = '{fails:['
			json += taggable_add_result[:failed].collect{|f| "'" + f.name + "'" }.join(',')
			json += ']}'
			json
		end
	end#ClassMethods
	
end#AddXmlJsonToTaggables
