class Cms::PageLayoutsController < ApplicationController
	layout 'admin'
	attr_reader :action_nav
	helper CW::ActionNav::View

	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time

	require_post_method_for :update_version, :create_schedule

	def index
		list
		render :action => 'list'
	end

	def list_pagination
		@pl_pag = CW::Pagination::Model::ActiveRecord.new( self, 'PageLayout', CW::SortOrder.asc('programmatic_name'), {}, Setting['vms-protected-items-per-page'].value_typed )
	end; protected :list_pagination

	def list
		@pl_pag = list_pagination
    @action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
      s.link 'export all published', { :action => 'export_published' }, { :title => 'Export the published layouts to a json format' }
      s.link 'import', { :action => 'import' }, { :title => 'Import the JSON-serialized layouts' }
    }
	end

	def info
		@page = PageLayout.find params[:id]
		@pl_pag = list_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'edit current version', { :action => 'edit_version', :id => @page.id, :version => @page.scheduled_version_current_or_last_version.version_number }, {:title => 'Edit the current version'}
		}.section('View') { |s|
			s.link 'history', { :action => 'versions', :id => @page.id }, {:title => 'See all changes to the page layout'}
			s.link 'schedule', { :action => 'schedule', :id => @page.id }, {:title => 'View when which page layout will appear at what time'}
		}
	end

	def version_pagination( p )
		CW::Pagination::Model::ActiveRecord.new( self, 'PageLayoutVersion', CW::SortOrder.desc('id'), {:conditions => ['version_stub_id = ?',p.id]}, Setting['vms-protected-items-per-page'].value_typed )
	end; protected :version_pagination

	def versions
		@page = PageLayout.find params[:id]
		@pl_pag = list_pagination
		@pl_v_pag = version_pagination( @page )
	end

	def edit_version
		@page = PageLayout.find( params[:id], :readonly => true )
		@page_old_version = @page.version( params[:version].to_i )
		raise ActiveRecord::RecordNotFound.new if @page_old_version.nil?
		@page_version = @page_old_version.new_from
		@pl_pag = list_pagination
		@pl_v_pag = version_pagination( @page )
	end

	def update_version
		edit_version

		@page_version.attributes=( params[:page_version] )
		@page_version.editor_id = session[:user_id]
		@pl_pag = list_pagination
		@pl_v_pag = version_pagination( @page )

		if @page_version.save
			if params[:save_and_publish]
        @page_schedule = PageLayoutScheduleDateRange.new( { 'start_at_is_nil' => '1', 'end_at_is_nil' => '1' } )
        @page_schedule.enforce_nil_start_end

        if @page_version.page_layout.scheduled_version_schedule_version_with_range( @page_version, @page_schedule )
          redirect_to :action => 'info', :id => @page_version.page_layout.id
        else
          render :action => 'new_schedule'
        end
			else
				flash[:msg] = "New version created! Version ##{@page_version.version_number}"
				redirect_to :action => 'version', :id => @page_version.id and return
			end
		else
			render :action => 'edit_version' and return
		end
	end

	def version
		@page_old_version = PageLayoutVersion.find( params[:id], :readonly => true )
		@page_version = @page_old_version #alias
		@page = @page_version.stub
		@pl_pag = list_pagination
		@pl_v_pag = version_pagination @page
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'schedule', { :action => 'new_schedule', :id => @page.id, :page_version => { :version => @page_version.version_number } }, {:title => 'Schedule when this version will appear'}
		}
	end

	def schedule_pagination( page )
		CW::Pagination::Model::ActiveRecord.new( self, 'PageLayoutScheduleDateRange', CW::SortOrder.desc('page_layout_schedule_date_ranges.start_at'), {:conditions => ['page_layout_schedule_date_ranges.exclusivity_id = ?',page.id]}, Setting['vms-protected-items-per-page'].value_typed, 'page' ).add_join_accessor('page_layout_schedule_date_ranges.start_at', Proc.new{|o| o.start_at} )
	end; protected :schedule_pagination

	def schedule
		@page = PageLayout.find params[:id], :readonly => true
		@pl_sched_pag = schedule_pagination( @page )
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'add', { :action => 'new_schedule', :id => @page.id }, {:title => 'Add a new schedule'}
		}
	end

	def new_schedule
		@page = PageLayout.find( params[:id], :readonly => true )
		@pl_sched_pag = schedule_pagination( @page )
		@page_schedule = PageLayoutScheduleDateRange.new
		begin
		v = params[:page_version][:version].to_i
		rescue
		v = 1
		end
		@page_version = PageLayoutVersionTemp.new( v )
		@page_schedule.start_at = Time.now
		@page_schedule.end_at = @page_schedule.start_at + 2.weeks
	end

	def create_schedule
		@page = PageLayout.find( params[:id] )
		@pl_sched_pag = schedule_pagination( @page )
		@page_schedule = PageLayoutScheduleDateRange.new( params[:page_schedule] )
		@page_schedule.enforce_nil_start_end
		@page_version = @page.version( params[:page_version][:version].to_i )
		if @page_version.nil?
			render :action => 'schedule'
		end

		if @page.scheduled_version_schedule_version_with_range( @page_version, @page_schedule )
			redirect_to :action => 'info', :id => @page.id
		else
			render :action => 'new_schedule'
		end
	end

	def preview
		@ver = PageLayoutVersion.find params[:id]
		redirect_to( :controller => '/' + @ver.page_layout.controller, :action => @ver.page_layout.action, :admin_page_layout_preview_version_id => @ver.id )
  end

  def export_published
    @layouts = PageLayout.all
    @versions = @layouts.map{|l| l.scheduled_version_current( @time )}
    serial_safe =  @versions.map{|l| { :programmatic_name => l.page_layout.programmatic_name, :layout => l.layout } }
    # for testing
    #serial_safe =  @versions.map{|l| { :programmatic_name => l.page_layout.programmatic_name, :layout => 'blank' } }
    render :inline => JSON.generate( serial_safe ), :content_type => 'text/json'
  end

  def import
    if request.get?
      render :action => 'import'
    elsif request.post?
      # try to import, render the import form on error
      raw = params[:import]



      layouts = JSON.parse(raw).each do |l|

        page = PageLayout.first( :conditions => {:programmatic_name => l['programmatic_name']}, :readonly => true )
        page_old_version = page.scheduled_version_current_or_last_version
        page_version = page_old_version.new_from
        page_version.layout = l['layout']
        page_version.version_comment = 'Imported on ' + Time.now.utc.rfc822
        page_version.save

        page_schedule = PageLayoutScheduleDateRange.new( { 'start_at_is_nil' => '1', 'end_at_is_nil' => '1' } )
        page_schedule.enforce_nil_start_end
        page_version.page_layout.scheduled_version_schedule_version_with_range( page_version, page_schedule )

      end

      redirect_to :action => 'index'

    else
      render :text => '405 Method not allowed', :status => 405
    end
  end



	class PageLayoutVersionTemp
		def initialize( v )
			@v = v
		end

		def version; @v; end
	end

end
