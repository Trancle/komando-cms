class Cms::UserInputBlacklistsController < ApplicationController
	layout 'admin'
	attr_reader :action_nav
	helper CW::ActionNav::View

	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time

	require_post_method_for :create, :update, :destroy, :test_result

	def index
		list
		render :action => 'list'
	end

	def list_pagination; CW::Pagination::Model::ActiveRecord.new( self, 'UserInputBlacklist', CW::SortOrder.asc('type').asc('value'), {}, Setting['vms-protected-items-per-page'].value_typed ); end; protected :list_pagination

	def list
		@word_pag = list_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'add', { :action => 'new_type' }, {:title => 'Add a new word that cannot be used in UGC'}
		}
	end

	def info
		@word = UserInputBlacklist.find params[:id]
		@word_pag = list_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'edit', { :action => 'edit', :id => @word.id }, {:title => 'Edit an existing blacklisted word'}
			s.link 'test', { :action => 'test', :id => @word.id }, {:title => 'Test blacklisted word to see if it will be blocked'}
			s.link 'destroy', { :action => 'destroy_confirm', :id => @word.id }, {:title => 'Destroy an existing blacklisted word'}
		}
	end

	def new_type
		@word = UserInputBlacklist.new
		@word_type = 'UserInputBlacklistRegularExpression'
	end

	def new
		@word_type = params[:word_type]
		if UserInputBlacklist.valid_subclass? @word_type
			@word = @word_type.constantize.new
		else
			render :action => 'new_type'
		end
	end

	def create
		@word_type = params[:word_type]
		if UserInputBlacklist.valid_subclass? @word_type
			@word = @word_type.constantize.new( params[:word] )
			if @word.save
				flash[:msg] = "New blacklist input created"
				redirect_to :action => 'info', :id => @word.id
			else
				render :action => 'new'
			end
		else
			render :action => 'new_type'
		end
	end

	def test
		@word = UserInputBlacklist.find params[:id]
		@value = ''
		@word_pag = list_pagination
	end

	def test_result
		@word = UserInputBlacklist.find params[:id]
		@value = params[:value]
		@blacklisted = @word.matches?( params[:value] )
		@word_pag = list_pagination
	end

	def edit
		@word = UserInputBlacklist.find params[:id]
		@word_pag = list_pagination
	end

	def update
		@word = UserInputBlacklist.find params[:id]
		if @word.update_attributes( params[:word] )
			flash[:msg] = "Blacklist input updated"
			redirect_to :action => 'info', :id => @word.id
		else
			render :action => 'new'
		end
	end

	def destroy_confirm
		@word = UserInputBlacklist.find params[:id]
		@word_pag = list_pagination
	end

	def destroy
		@word = UserInputBlacklist.find params[:id]
		@word_pag = list_pagination
		pn = @word_pag.page_number_of_item( @word )
		@word.destroy
		flash[:msg] = 'Blacklist input removed'
		redirect_to :action => 'list', :page => pn
	end

end
