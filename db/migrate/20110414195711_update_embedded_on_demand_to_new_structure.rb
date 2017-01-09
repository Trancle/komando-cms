class UpdateEmbeddedOnDemandToNewStructure < ActiveRecord::Migration
  def self.up
		# Let's start easy: CNN
		say_with_time 'Updating CNN Embedded Videos...' do
			up_cnn
		end
		say_with_time 'Updating Vimeo Embedded Videos...' do
			up_vimeo
		end
		say_with_time 'Updating YouTube Embedded Videos...' do
			up_you_tube
		end
		say_with_time 'Updating CBS Embedded Videos...' do
			up_cbs
		end
		say_with_time 'Updating HTML Embedded Videos...' do
			up_html
		end
  end

  def self.down
		raise ActiveRecord::IrreversibleMigration.new
  end

	def self.up_cnn
		# CNN is difficult as it has a very loose API that is very delicate. We also only have 2 or three in customer databases
		# Example type_information:
# cnn+http://offbeat/2010/03/24/moos.chatroulette.piano.duel.cnn
# Example output:
#<object style="width: 620px; height: 349px;" id="unique_player_id_required_by_ie_stupidness" type="application/x-shockwave-flash" data="http://i.cdn.turner.com/cnn/.element/apps/cvp/3.0/swf/cnn_416x234_embed.swf?context=embed&amp;videoId=offbeat/2010/03/24/moos.chatroulette.piano.duel.cnn" class="player">
#<param name="allowfullscreen" value="true" />
#<param name="allowscriptaccess" value="always" />
#<param name="wmode" value="transparent" />
#<param name="movie" value="http://i.cdn.turner.com/cnn/.element/apps/cvp/3.0/swf/cnn_416x234_embed.swf?context=embed&amp;videoId=offbeat/2010/03/24/moos.chatroulette.piano.duel.cnn" />
#<param name="bgcolor" value="#000000" />
#</object>
# 

		VideoContentEmbeddedOnDemand.find( :all, :conditions => "type_information like 'cnn+http://%' and type = 'VideoContentEmbeddedOnDemand'" ).each do |vc|
			VideoContentEmbeddedOnDemand.transaction do
				# Change the type
				vc.type = 'VideoContentEmbeddedOnDemandHTML'
				vc.save
				# Reload the class
				vc = VideoContentEmbeddedOnDemandHTML.find( vc.id )
				# Now have HTML type
				# Extract the old data
				video_id, opts = vc.legacy_embed_code_parse_parameters( vc.type_information.strip )
				vc.raw = <<EOD
	<object id="unique_player_id_required_by_ie_stupidness" type="application/x-shockwave-flash" data="http://i.cdn.turner.com/cnn/.element/apps/cvp/3.0/swf/cnn_416x234_embed.swf?context=embed&amp;videoId=#{video_id}" class="player">
	<param name="allowfullscreen" value="true" />
	<param name="allowscriptaccess" value="always" />
	<param name="wmode" value="transparent" />
	<param name="movie" value="http://i.cdn.turner.com/cnn/.element/apps/cvp/3.0/swf/cnn_416x234_embed.swf?context=embed&amp;videoId=#{video_id}" />
	<param name="bgcolor" value="#000000" />
	</object>
EOD
				# Save the data
				vc.save
			end
		end
	end

	def self.up_vimeo
		# Vimeo upgrades should be relatively simple. There aren't very many of these floating around either.
		VideoContentEmbeddedOnDemand.find( :all, :conditions => "type_information like 'vimeo+http://%' and type = 'VideoContentEmbeddedOnDemand'" ).each do |vc|
			VideoContentEmbeddedOnDemand.transaction do
				# Change the type
				video_id, opts = vc.legacy_embed_code_parse_parameters( vc.type_information.strip )
				vc.type = 'VideoContentEmbeddedOnDemandVimeo'
				vc.save
				# Reload the class
				vc = VideoContentEmbeddedOnDemandVimeo.find( vc.id )
				# Now have the correct type
				# Extract the old data & use only default options
				vc.video_id = video_id
				# Raw is a left-over component from the conversion process, it can be deleted safely from all non-HTML models
				vc.embed_attrs.delete( 'raw' )
				# Save the data
				vc.save
			end
		end
	end

	def self.up_html
		# HTML upgrades should be relatively simple. There aren't very many of these floating around either.
		VideoContentEmbeddedOnDemand.find( :all, :conditions => "not type_information like 'vimeo+http://%' and not type_information like 'youtube+http://%' and not type_information like 'cnn+http://%' and type = 'VideoContentEmbeddedOnDemand'" ).each do |vc|
			VideoContentEmbeddedOnDemand.transaction do
				html = vc.type_information
				# Change the type
				vc.type = 'VideoContentEmbeddedOnDemandHTML'
				vc.save
				# Reload the class
				vc = VideoContentEmbeddedOnDemandHTML.find( vc.id )
				# Now have the correct type
				# Extract the old data & use only default options
				vc.raw = html
				# Save the data
				vc.save
			end
		end
	end

	def self.up_you_tube
		VideoContentEmbeddedOnDemand.find( :all, :conditions => "type_information like 'youtube+http://%' or type_information like '\"youtube+http://%' and type = 'VideoContentEmbeddedOnDemand'" ).each do |vc|
			VideoContentEmbeddedOnDemand.transaction do
				# Change the type
				video_id, opts = vc.legacy_embed_code_parse_parameters( vc.type_information.strip )
				vc.type = 'VideoContentEmbeddedOnDemandYouTube'
				vc.save
				# Reload the class
				vc = VideoContentEmbeddedOnDemandYouTube.find( vc.id )
				# Now have the correct type
				# Extract the old data & use only default options
				vc.video_id = video_id
				# Raw is a left-over component from the conversion process, it can be deleted safely from all non-HTML models
				vc.embed_attrs.delete( 'raw' )
				# Save the data
				vc.save
			end
		end
	end

	def self.up_cbs
		# CBS is a brand-new support class. We're doing this to elminate the custom embeds that are running rampant throughout customer databases
		# When CBS provides a player that will work with HTML5 better later, it will be eaiser to update to this version once it's available
		# Embedding now is very haphazard
		VideoContentEmbeddedOnDemand.find( :all, :conditions => "type_information like '<embed src=\"http://cnettv.cnet.com/av/video/cbsnews/atlantis2/cbsnews_player_embed.swf\"%' and type = 'VideoContentEmbeddedOnDemand'" ).each do |vc|
			VideoContentEmbeddedOnDemand.transaction do
				# We need the ID for this video before we proceed
				m = vc.type_information.match(/contentValue=(\d+)/i)
				video_id = m[1]

				# Change the type
				vc.type = 'VideoContentEmbeddedOnDemandCBS'
				vc.save
				# Reload the class
				vc = VideoContentEmbeddedOnDemandCBS.find( vc.id )
				# Now have the correct type
				# Extract the old data & use only default options
				vc.video_id = video_id
				# Raw is a left-over component from the conversion process, it can be deleted safely from all non-HTML models
				vc.embed_attrs.delete( 'raw' )
				# Save the data
				vc.save
			end
		end
	end

end
