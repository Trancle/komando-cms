class EpisodeDrop < BaseDrop
	include ShowsHelper

	def initialize( episode, episode_version, free_status, episode_still_image, video_contents, show, show_version, controller, time = Time.now.utc, options = {} )
		@episode = episode
		@episode_version = episode_version
		@episode_still_image = episode_still_image
		@show = show
		@show_version = show_version
		@options = options
		@controller = controller
    @video_contents = video_contents
    @free_status = free_status
		@time = time
	end

	def episode_id
		@episode.id
	end

	def total_length_in_seconds
		@episode.total_length_in_seconds( @video_contents )
	end

	def total_length_in_seconds_as_i
		self.total_length_in_seconds.to_i
	end

	def total_length_in_words
		t = Time.now
		distance_of_time_in_words( t, t + total_length_in_seconds_as_i, true )
	end

	def total_length_as_hh_mm_ss
		@episode.total_length_as_hh_mm_ss( @video_contents )
	end

	def total_length_as_hh_mm_ss_colon_separators
		i = 0

		ar = @episode.total_length_as_hh_mm_ss( @video_contents )

		ar = [0] if ar.empty?

		if ar[0].eql?0
			ar.shift
		end

		# change seconds to always include a leading zero, but only if there's more than 1 element
		ar[ar.size-1] = '0' + ar.last.to_s if ar.size > 1 and ar.last < 10 

		ar.join(':')
	end

	def title
		@episode_version.title
	end

	def description
		@episode_version.description || ''
	end

	def episode_number
		@episode_version.episode_number || ''
	end

	def season_number
		@episode_version.season_number || ''
	end

	def free_days_available_remaining
		r = @episode.current_free_range( @time )
		if r.nil
			0
		else
			self.class.seconds_to_days( (r.end_at - @time).to_f )
		end
	end

	def is_free
		@free_status
	end

	def days_available_remaining
		r = @episode.current_available_range( @time )
		if r.nil
			0
		else
			self.class.seconds_to_days( (r.end_at - @time).to_f )
		end
	end

	def show
		ShowDrop.new( @show, @show_version, @controller, @time, @options )
	end

  def still_image_tag
    image_tag( @episode_still_image.virtual_path, :alt => @episode_still_image.alt_text ) if @episode_still_image
  end

  def still_image_ext
    @episode_still_image.file_extension if @episode_still_image
  end

  def still_image_hash
    @episode_still_image.file_hash if @episode_still_image
  end

	def url_to_watch
		url_for( url_to_episode(@show_version,@episode_version) )
  end

  def published_datetime
    @episode.published_datetime
  end

  def tag_list
    @episode.tags.map{|t| t.tag}.join(', ')
  end

  def tags
    @episode.tags.map{|t| TagDrop.new(t)}
  end

  # true if live episode, false if not live
  def is_live
    unless @episode.video_content_names.empty?
      unless @episode.video_content_names.first.video_contents.empty?
        return @episode.video_content_names.first.video_contents.first.is_a?(VideoContentHostedLive)
      end
    end
  end


	protected

	def self.seconds_to_days( s )
		(s/86400.0).ceil
	end

end
