class Cms::RelatedShowsController < ApplicationController
	layout 'admin'

	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time

	require_post_method_for :destroy, :create


	def show
		@show = Show.find( params[:id] )
		@pagination = CW::Pagination::Model::ActiveRecord.new( self, 'LinkShowToRelatedShow', CW::SortOrder.desc('id'), {:conditions => ['show_id = ?',@show.id]}, Setting['vms-protected-items-per-page'].value_typed )
#@pagination, @links = pagination_of_simple( LinkShowToRelatedShow, Pagination::Book.new( Setting['vms-protected-items-per-page'].value_typed ), :conditions => ['show_id = ?',@show.id] )
	end

	def new
		@show = Show.find( params[:id] )
		@link = LinkShowToRelatedShow.new
		@link.show_id = @show.id
	end

	def create
		@show = Show.find( params[:id] )
		@link = LinkShowToRelatedShow.new( params[:link] )
		@link.show_id = @show.id
		if @link.save
			flash[:msg] = 'Show linked to another show'
			redirect_to :action => 'show', :id => @show.id
		else
			render :action => 'new'
		end
	end

	def confirm_destroy
		@link = LinkShowToRelatedShow.find params[:id]
		@show = Show.find( @link.show_id )
	end

	def destroy
		@link = LinkShowToRelatedShow.find params[:id]
		@link.destroy
		flash[:msg] = 'Show is no longer related'
		redirect_to :action => 'show', :id => @link.show_id
	end

end
