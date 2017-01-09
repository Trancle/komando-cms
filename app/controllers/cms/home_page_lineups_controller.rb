class Cms::HomePageLineupsController < ApplicationController
	layout 'admin'

	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time

	require_post_method_for :create, :update, :create_schedule, :create_link_with_video_content_name, :destroy_link_with_video_content_name, :destroy, :move_link_up, :move_link_down, :destroy_schedule, :update_schedule

	def index
		@pagination = CW::Pagination::Model::ActiveRecord.new( self, 'HomePageLineup', CW::SortOrder.desc('created_at'), {}, Setting['vms-protected-items-per-page'].value_typed )
#@pagination, @lineups = pagination_of_simple( HomePageLineup, Pagination::Book.new( Setting['vms-protected-items-per-page'].value_typed ), { :order => 'created_at DESC' } )

		opts = HomePageLineupDateRange.find_all_in_range_options( HomePageLineupDateRange.table_name, nil, Time.now.utc )
		opts[:order] = 'start_at'
		opts[:limit] = 10
		raise opts.inspect
		@schedules = HomePageLineupDateRange.find( :all, opts )
	end

	def new
		@home_page_lineup = HomePageLineup.new
	end

	def create
		@home_page_lineup = HomePageLineup.new( params[:home_page_lineup] )
		if @home_page_lineup.save
			flash[:msg] = 'New lineup created'
			redirect_to :action => 'info', :id => @home_page_lineup.id
		else
			render :action => 'new'
		end
	end

	def info
		@home_page_lineup = HomePageLineup.find params[:id], :readonly => true
		opts = HomePageLineup.find_video_content_name_by_lineup_id_options( @home_page_lineup.id )
		@pagination = CW::Pagination::Model::ActiveRecord.new( self, 'LinkHomePageLineupWithVideoContentName', LinkHomePageLineupWithVideoContentName.order_sort_order, opts, Setting['vms-protected-items-per-page'].value_typed )
#@pagination, @links = pagination_of_simple( LinkHomePageLineupWithVideoContentName, Pagination::Book.new( Setting['vms-protected-items-per-page'].value_typed ), LinkHomePageLineupWithVideoContentName.order_options().merge(opts) )
	end

	def edit
		info
	end

	def update
		@home_page_lineup = HomePageLineup.find params[:id]
		if @home_page_lineup.update_attributes( params[:home_page_lineup] )
			flash[:msg] = 'lineup updated'
			redirect_to :action => 'info', :id => @home_page_lineup.id
		else
			render :action => 'edit'
		end
	end

	def schedules
		@pagination, @schedules = pagination_of_simple( HomePageLineupDateRange, Pagination::Book.new( Setting['vms-protected-items-per-page'].value_typed ), { :order => 'start_at DESC, end_at DESC' } )
	end

	def new_schedule
		info
		@schedule = HomePageLineupDateRange.new
		@schedule.start_at = Time.now
		@schedule.end_at = @schedule.start_at + 2.weeks
	end

	def create_schedule
		info
		@schedule = HomePageLineupDateRange.new( params[:schedule] )
		@schedule.enforce_nil_start_end
		# always ID = 1 so all are tagged with mutual exclusivity
		@schedule.exclusivity_id = 1
		# link up home page id to it
		@schedule.home_page_lineup_id = @home_page_lineup.id
		if @schedule.save
			flash[:msg] = 'Line up now scheduled'
			redirect_to :action => 'info', :id => @home_page_lineup.id
		else
			render :action => 'new_schedule'
		end
	end

	def new_link_with_video_content_name
		info
		@link = LinkHomePageLineupWithVideoContentName.new
		@link.home_page_lineup_id = @home_page_lineup.id
	end

	def create_link_with_video_content_name
		info
		@link = LinkHomePageLineupWithVideoContentName.new( params[:link] )
		@link.home_page_lineup_id = @home_page_lineup.id
		if @link.save
			flash[:msg] = 'Lineup linked with video content'
			redirect_to :action => 'info', :id => @home_page_lineup.id
		else
			render :action => 'new_link_with_video_content_name'
		end
	end

	def confirm_destroy_link_with_video_content_name
		@link = LinkHomePageLineupWithVideoContentName.find params[:id], :readonly => true
	end

	def destroy_link_with_video_content_name
		@link = LinkHomePageLineupWithVideoContentName.find params[:id]
		@link.destroy
		flash[:msg] = 'Lineup no longer linked with video content'
		redirect_to :action => 'info', :id => @link.home_page_lineup_id
	end

	def confirm_destroy
		info
	end

	def destroy
		@home_page_lineup = HomePageLineup.find params[:id]
		@home_page_lineup.destroy
		flash[:msg] = 'Lineup destroyed'
		redirect_to :action => 'index'
	end

	def move_link_up
		@link = LinkHomePageLineupWithVideoContentName.find params[:id]
		@link.move_order_up
		flash[:msg] = 'Moved up'
		redirect_to :action => 'info', :id => @link.home_page_lineup_id
	end

	def move_link_down
		@link = LinkHomePageLineupWithVideoContentName.find params[:id]
		@link.move_order_down
		flash[:msg] = 'Moved down'
		redirect_to :action => 'info', :id => @link.home_page_lineup_id
	end

	def confirm_destroy_schedule
		@schedule = HomePageLineupDateRange.find( params[:id] )
	end

	def destroy_schedule
		@schedule = HomePageLineupDateRange.find( params[:id] )
		@schedule.destroy
		flash[:msg] = 'Schedule destroyed'
		redirect_to :action => 'schedules'
	end

	def edit_schedule
		@schedule = HomePageLineupDateRange.find( params[:id] )
		@home_page_lineup = @schedule.home_page_lineup
	end

	def update_schedule
		@schedule = HomePageLineupDateRange.find( params[:id] )
		@home_page_lineup = @schedule.home_page_lineup
		@schedule.enforce_nil_start_end
		if @schedule.update_attributes( params[:schedule] )
			flash[:msg] = "Schedule updated"
			redirect_to :action => 'schedules'
		else
			render :action => 'edit_schedule'
		end
	end

end
