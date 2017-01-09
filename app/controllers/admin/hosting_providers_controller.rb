class Admin::HostingProvidersController < ApplicationController
	layout 'admin'
	attr_reader :action_nav
	helper CW::ActionNav::View

	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time

	require_post_method_for :destroy, :update, :create, :deprecate, :undeprecate

	def index
		list
		render :action => 'list'
	end

	def list_pagination; CW::Pagination::Model::ActiveRecord.new( self, 'VideoContentHostingProvider', CW::SortOrder.asc('name'), {}, Setting['vms-protected-items-per-page'].value_typed ); end; protected :list_pagination
	def list
		@type_limit = params[:id]
		if @type_limit and VideoContentHostingProvider.is_valid_subclass?( @type_limit )
			@pagination = CW::Pagination::Model::ActiveRecord.new( self, 'VideoContentHostingProvider', CW::SortOrder.asc('name'), {:conditions => ['video_content_hosting_providers.type = ?)',@type_limit]}, Setting['vms-protected-items-per-page'].value_typed )
		else
			@pagination = list_pagination
		end
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'add', {:action => 'new'}, {:title => 'Create a new provider'}
		}
	end

	def new
		@provider = VideoContentHostingProvider.new
	end

	def new_type
		provider_type = params[:provider][:type]
		if VideoContentHostingProvider.valid_sub_subclass?(provider_type)
			@provider = provider_type.constantize.new
		else
			redirect_to :action => 'new'
		end
	end

	def create
		new_type
		@provider.attributes=( params[:provider] )
		if @provider.save
			flash[:message] = 'Provider created'
			redirect_to :action => 'info', :id => @provider.id
		else
			render :action => 'new_type'
		end
	end

	def edit
		info
	end

	def update
		info
		if @provider.update_attributes( params[:provider] )
			flash[:msg] = "Provider updated"
			redirect_to :action => 'info', :id => @provider.id
		else
			render :action => 'edit'
		end
	end

	def info
		@provider = VideoContentHostingProvider.find params[:id]
		@pagination = list_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'edit', {:action => 'edit', :id => @provider.id}, {:title => 'Update this provider\'s information'}
			if @provider.deprecated?
				s.link 'undeprecate', {:action => 'undeprecate_confirm', :id => @provider.id}, {:title => 'Allow this provider to be used again for new videos'}
			else
				s.link 'deprecate', {:action => 'deprecate_confirm', :id => @provider.id}, {:title => 'Stop this provider from being used for new videos'}
			end
			s.button 'destroy', {:action => 'destroy_confirm', :id => @provider.id}, {:class => 'button', :title => 'Destroy this provider'}
		}
	end

	def destroy_confirm
		@provider = VideoContentHostingProvider.find params[:id]
		if @provider.used?
			flash[:msg] = 'This provider is currently is use and may NOT be deleted'
			redirect_to :action => 'info', :id => @provider.id and return
		end
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.button 'destroy', {:action => 'destroy', :id => @provider.id}, {:class => 'button', :title => 'Destroy this provider'}
		}
	end

	def destroy
		@provider = VideoContentHostingProvider.find params[:id]
		if @provider.used?
			flash[:msg] = 'This provider is currently is use and may NOT be deleted'
			redirect_to :action => 'info', :id => @provider.id and return
		else
			@provider.destroy
			flash[:msg] = "Provider deleted"
			redirect_to :action => 'list'
		end
	end

	def deprecate_confirm
		@provider = VideoContentHostingProvider.find params[:id]
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.button 'deprecate', {:action => 'deprecate', :id => @provider.id}, {:class => 'button', :title => 'Deprecate this provider'}
		}
	end

	def deprecate
		@provider = VideoContentHostingProvider.find params[:id]
		@provider.deprecated = true
		if @provider.save
			flash[:msg] = "Provider is now deprecated"
		else
			render :action => 'deprecate_confirm'
		end
		redirect_to :action => 'info', :id => @provider.id
	end

	def undeprecate_confirm
		deprecate_confirm # steal from deprecate, essentially the same
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.button 'undeprecate', {:action => 'undeprecate', :id => @provider.id}, {:class => 'button', :title => 'UnDeprecate this provider'}
		}
	end

	def undeprecate
		@provider = VideoContentHostingProvider.find params[:id]
		@provider.deprecated = false
		if @provider.save
			flash[:msg] = "Provider is now deprecated"
		else
			render :action => 'undeprecate_confirm'
		end
		redirect_to :action => 'info', :id => @provider.id
	end

end
