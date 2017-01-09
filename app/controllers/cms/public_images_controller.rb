class Cms::PublicImagesController < ApplicationController
	layout 'admin'
	attr_reader :action_nav
	helper CW::ActionNav::View


	skip_filter :enable_admin_layout_preview
	skip_filter :enable_admin_preview_at_time
	require_post_method_for :create, :destroy, :update

	def self.default_managed_file_resource_controller; Cms::EpisodeStills; end

	def index
		list
	end

	def list_pagination( query = {} )
		CW::Pagination::Model::ActiveRecord.new( self, 'PublicImage', CW::SortOrder.desc('created_at'), query, Setting['vms-protected-items-per-page'].value_typed )
	end; protected :list_pagination

	def list
		limits = params[:limits]
		opts = {}
		opts = { :conditions => ['type = ?',limits['only']['type']] }	if !limits.nil? and !limits['only'].nil? and !limits['only']['type'].nil?

		@pi_pag = list_pagination( opts )
		respond_to do |format|
# Creates a JSON version of the page
			format.json {
				render :json => '{"items": [' + @pi_pag.items_for_current_page.collect{|x| x.to_json(:methods => [:virtual_path])}.join(',') + '], "total_number_of_pages": ' + (@pi_pag.count_pages).to_s + ', "total_number_of_items": ' + @pi_pag.count_items.to_s + ' }'
			}
			format.html {
				@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
					s.link 'add', { :action => 'new' }, {:title => 'Add a new image'}
				}
				render :action => 'list' and return
			}
		end
	end

	def new
		@public_image = PublicImage.new
		@image_type = ''
	end

	def create
		@image_type = params[:image_type]
		if PublicImage.is_valid_subclass_name?(@image_type)
			@public_image = @image_type.constantize.new( params[:public_image].reject{|p,v| p.eql?'file_path'} )
			if @public_image.upload( params[:public_image] )
				if @public_image.save
					redirect_to :action => 'info', :id => @public_image.id
				else
					render :action => 'new'
				end
			else
				render :action => 'new'
			end
		else
			@public_image = PublicImage.new
			@public_image.errors.add_to_base 'Select what type of image to create'
			render :action => 'new'
		end
	end

	def info
		@public_image = PublicImage.find( params[:id] )
		@pi_pag = list_pagination
		respond_to do |format|
			format.html {
				@action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
					s.link 'edit', { :action => 'edit', :id => @public_image.id }, {:title => 'Update the image ALT text'}
					s.link 'destroy', { :action => 'destroy_confirm', :id => @public_image.id }, {:title => 'Remove this image'}
				}
			}
			format.json {
				render :json => @public_image
			}
			format.xml {
				render :xml => @public_image
			}
		end
	end

	def edit
		@public_image = PublicImage.find( params[:id] )
		@pi_pag = list_pagination
	end

	def update
		@public_image = PublicImage.find( params[:id] )
		@public_image.alt_text = params[:public_image]['alt_text']
		@pi_pag = list_pagination
		if @public_image.save
			flash[:msg] = "Image updated"
			redirect_to :action => 'info', :id => @public_image.id
		else
			render :action => 'edit'
		end
	end

	def count
		limits = params[:limits]
		opts = {}
		opts.merge!( :conditions => ['type = ?',limits['only']['type']] )	if !limits.nil? and !limits['only'].nil? and !limits['only']['type'].nil?
		@count = PublicImage.count( opts )
		respond_to do |format|
			format.html { render :inline => "<h1>Public Images Count</h1><p>#{@count}</p>", :layout => true }
			format.json { render :json => "{ count: #{@count} }" }
		end
	end

	def destroy_confirm
		@public_image = PublicImage.find( params[:id] )
		@pi_pag = list_pagination
	end

	def destroy
		@public_image = PublicImage.find( params[:id] )
		@pi_pag = list_pagination
		pn = @pi_pag.page_number_of_item( @public_image )
		@public_image.destroy
		flash[:msg] = "Image destroyed"
		redirect_to :action => 'index', :page => pn
	end

end
