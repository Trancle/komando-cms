class ShowDrop < BaseDrop
	include ShowsHelper
	include CW::ManagedFileResource::ViewHelper

	def initialize( show, show_version, controller, time = Time.now.utc, options = {} )
		@show = show
		@show_version = show_version
		@time = time
		@controller = controller
		@options = options
	end

	def show_id
		@show.id
	end

	def related_shows
		self.related_shows.collect do |show|
			ShowDrop.new( show, show.scheduled_version_current(@time), @time, @options )
		end
	end

	def title
		@show_version.title
	end

	def description
		@show_version.description
	end

	def keywords
		@show.keywords
	end

	def availability_notes
		@show_version.availability_notes
	end

	def still_image_tag
		image_tag( @show_version.show_still_image.virtual_path, :alt => @show_version.show_still_image.alt_text ) if @show_version.show_still_image
  end

  def still_image_hash
    @show_version.show_still_image.file_hash  if @show_version.show_still_image
  end

  def still_image_ext
    @show_version.show_still_image.file_extension  if @show_version.show_still_image
  end

	def splash_image_tag
		image_tag( @show_version.show_splash_image.virtual_path, :alt => @show_version.show_splash_image.alt_text ) if @show_version.show_splash_image
	end

  def splash_image_hash
    @show_version.show_splash_image.file_hash  if @show_version.show_splash_image
  end

  def splash_image_ext
    @show_version.show_splash_image.file_extension  if @show_version.show_splash_image
  end

	def url_to_show_page
		url_for( url_to_show( @show_version ) )
	end

	def url_to_watch_latest_episode
		latest = @show.latest_episode( { :include => 'current_version' }, @time )
		unless latest.nil?
			epv = latest.current_version
			url_for( url_to_episode(@show_version,epv)  )
		else
			url_for( url_to_show(@show_version) )
		end
	end

end
