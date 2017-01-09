class Cms::ShowCategoriesController < ApplicationController
	layout 'admin'
	attr_reader :action_nav
	helper CW::ActionNav::View

	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time

	require_post_method_for :create, :update, :destroy

	def index
		list
		render :action => 'list'
	end

	def list_pagination
		CW::Pagination::Model::ActiveRecord.new( self, 'ShowCategory', CW::SortOrder.asc('name'), {}, Setting['vms-protected-items-per-page'].value_typed )
	end; protected :list_pagination

	def list
		@pagination = list_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'add', { :action => 'new' }, {:title => 'Create a new category'}
		}
	end

	def info
		@category = ShowCategory.find params[:id]
		@pagination = list_pagination
		@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
			s.link 'edit', { :action => 'edit', :id => @category.id }, {:title => 'Create a new category'}
			s.link 'destroy', { :action => 'destroy_confirm', :id => @category.id }, {:title => 'Create a new category'}
		}
	end

	def new
		@category = ShowCategory.new
	end

	def create
		@category = ShowCategory.new( params[:category] )
		if @category.save
			flash[:msg] = "New category created"
			redirect_to :action => 'info', :id => @category.id
		else
			render :action => 'new'
		end
	end

	def edit
		@category = ShowCategory.find params[:id]
		@pagination = list_pagination
	end

	def update
		@category = ShowCategory.find params[:id]
		@pagination = list_pagination
		if @category.update_attributes( params[:category] )
			flash[:msg] = "Category updated"
			redirect_to :action => 'info', :id => @category.id
		else
			render :action => 'edit'
		end
	end

	def destroy_confirm
		@category = ShowCategory.find params[:id]
		@pagination = list_pagination
	end

	def destroy
		@category = ShowCategory.find params[:id]
		@pagination = list_pagination
		pn = @pagination.page_number_of_item( @category )
		@category.destroy
		flash[:msg] = 'Category destroyed'
		redirect_to :action => 'list', :page => pn
	end


end
