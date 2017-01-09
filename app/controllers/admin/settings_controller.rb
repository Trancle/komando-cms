class Admin::SettingsController < ApplicationController
	layout 'admin'
	attr_reader :action_nav
	helper CW::ActionNav::View


	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time

	require_post_method_for :destroy, :create, :update

	def list_pagination
		CW::Pagination::Model::ActiveRecord.new( self, 'Setting', CW::SortOrder.asc('name'), {}, Setting['vms-protected-items-per-page'].value_typed )
	end; protected :list_pagination

	def index
		list
		render :action => 'list'
	end

	def list
		@pagination = list_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'add', { :action => 'new_type' }, { :title => 'Creates a new setting' }
		}
	end

	def new_type
		@setting = Setting.new
		@setting_type = ''
	end

	def new
		@setting_type = params[:setting_type]
		if Setting.valid_subclass?( @setting_type )
			@setting = @setting_type.constantize.new
		else
			@setting = Setting.new
			render :action => 'new_setting'
		end
	end

	def create
		@setting = Setting.new
		@setting_type = params[:setting_type]
		if Setting.valid_subclass?( @setting_type )
			@setting = @setting_type.constantize.new( params[:setting] )
			if @setting.protected?
				@setting.errors.add( :programmatic_name, 'cannot use the protected programmatic name' )
				render :action => 'new' and return
			end
			if @setting.save
				flash[:msg] = "Setting created"
				redirect_to :action => 'info', :id => @setting.id
			else
				render :action => 'new'
			end
		else
			@setting = Setting.new
			render :action => 'new_setting'
		end
	end

	def edit
		@setting = Setting.find( params[:id] )
		@pagination = list_pagination
	end

	def update
		@setting = Setting.find( params[:id] )
		@pagination = list_pagination
		# protect these
		params[:setting].delete( 'previous_value' )
		params[:setting].delete( 'programmatic_name' )
		params[:setting].delete( 'description' ) if @setting.protected?
		@setting.store_previous_value
		@setting.value = ''
		if @setting.update_attributes( params[:setting] )
			flash[:msg] = "Setting updated"
			redirect_to :action => 'info', :id => @setting.id
		else
			render :action => 'edit'
		end
	end

	def info
		@setting = Setting.find( params[:id] )
		@pagination = list_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'edit', { :action => 'edit', :id => @setting.id }, { :title => 'Changes an existing setting' }
			s.link 'destroy', { :action => 'destroy_confirm', :id => @setting.id }, { :title => 'Deletes a setting, if possible' } unless @setting.protected?
		}
	end

	def destroy_confirm
		@setting = Setting.find params[:id]
		@pagination = list_pagination
	end

	def destroy
		@setting = Setting.find params[:id]
		@pagination = list_pagination
		pn = @pagination.page_number_of_item( @setting )
		if !@setting.protected? and @setting.destroy
			flash[:msg] = 'Setting destroyed'
			redirect_to :action => 'index'
		else
			# FIXME: What if not destroyed?
		end
	end

end
