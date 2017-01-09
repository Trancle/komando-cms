class HomeController < ApplicationController
	layout 'home'

	skip_filter :require_login
	skip_filter :require_administrator_user

	def home
    override_expires_in 5.minutes, :public => true # OK to cache this page. Upon login, the cache will ignore it as it has a cookie
    blocks = HomePageBlock.find_in_order( {:conditions => { :visible => true }} ).reverse
    @blocks = []
    blocks.each do |block|
      episodes = block.episodes
      ep_drops = []
      unless episodes.empty?
        ranges = EpisodeFreeScheduleDateSet.find_ranges_with_exclusivity_ids_including( 'episode_free_schedule_dates', episodes.collect{|e|e.id}, @time )
        episode_free_status = EpisodeFreeScheduleDate.all(:conditions => ranges)

        ep_drops = episodes.map{|e|
          EpisodeDrop.new(e,e.current_version,!episode_free_status.detect{|s|
            s.exclusivity_id.eql?(e.id)
          }.nil?,e.current_version.episode_still_image,e.video_content_names.map{|vcn|
            vcn.video_contents
          }.flatten,e.show,e.show.scheduled_version_current_or_last_version,self,@time)
        }
      end

      @blocks << HomePageBlockDrop.new( block, ep_drops )
    end
		@layout = ( @layout_override || PageLayout.first( :conditions => "programmatic_name = 'home-home-page'" ).scheduled_version_current( @time ) ).layout
	end

end
