require 'test/unit'
require 'cw-bread-crumbs'
require 'rubygems'
#require 'ruby-debug'

class User
	attr_accessor :name
end

class Request
	attr_accessor :controller_name, :action_name
	def symbolized_path_parameters
		{ :controller => @controller_name, :action => @action_name }
	end
end
class ActionController
	attr_accessor :request
	attr_accessor :user
end
ActionController.send(:include,CW::BreadCrumbs::Controller)
ActionController::BreadCrumbs::Crumbs.draw do |map|
	map.c( { :controller => 'dashboard', :action => 'index' }, 'Dashboard' ) { |d|
		d.c( { :controller => 'users', :action => 'index' }, 'User Dash' )
		d.c( { :controller => 'users', :action => 'list' }, 'Users', { :custom => true } ) { |u|
			u.c( { :action => 'show' }, Proc.new{|controller| 'About: ' + controller.user.name } ) { |u|
				u.c( { :action => 'edit' }, Proc.new{|controller| 'Change: ' + controller.user.name } )
				u.alias( :action => 'update' )
			}
		}
		d.c( { :controller => 'books', :action => 'list' }, 'Books' ) { |b|
			b.c( { :action => 'show' }, Proc.new{ |controller| controller.book.title } ) { |b|
				b.c( { :action => 'edit' }, 'Edit' )
				b.c( { :action => 'new' }, 'New' )
				b.alias( :action => 'create' )  # Creates an alias for "New"
				b.c( { :action => 'destroy' }, 'Destroy' )
				b.c( { :action => 'update' }, 'Update' )
			}
		}
		d.c( { :controller => 'animes', :action => 'list' }, 'Animes' ) { |a|
			a.scaffold # Creates a bread crumb chain identical to the books one above, but for anime
		}
		d.c( { :controller => 'mangas', :action => 'list' }, 'Mangas' ) { |a|
			a.scaffold # Creates a bread crumb chain identical to the books one above, but for mangas
		}
	}
end

class BreadCrumbTest < Test::Unit::TestCase
	include CW::BreadCrumbs::ViewHelper
	attr_reader :controller

	def setup
		@crumbs = ActionController::BreadCrumbs::Crumbs
		@controller = ActionController.new
		@controller.request = Request.new
	end

	def teardown
	end

	def test_simple_bakery
		assert_equal [{ :controller => 'users', :action => 'edit' },{ :controller => 'users', :action => 'show' },{ :controller => 'users', :action => 'list' },{ :controller => 'dashboard', :action => 'index' }], @crumbs.crumb_chain( { :controller => 'users', :action => 'edit' } ).collect{|c| c.url}

		assert_equal [{ :controller => 'users', :action => 'edit' }], @crumbs.crumb_chain( { :controller => 'users', :action => 'edit' }, 1 ).collect{|c| c.url}

		assert_equal [{ :controller => 'users', :action => 'edit' },{ :controller => 'users', :action => 'show' }], @crumbs.crumb_chain( { :controller => 'users', :action => 'edit'}, 2 ).collect{|c| c.url}

		assert_equal [{ :controller => 'users', :action => 'show' },{ :controller => 'users', :action => 'list' },{ :controller => 'dashboard', :action => 'index' }], @crumbs.crumb_chain( { :controller => 'users', :action => 'show' } ).collect{|c| c.url}

		assert_equal [{ :controller => 'users', :action => 'list' },{ :controller => 'dashboard', :action => 'index' }], @crumbs.crumb_chain( { :controller => 'users', :action => 'list' } ).collect{|c| c.url}

		assert_equal [{ :controller => 'dashboard', :action => 'index' }], @crumbs.crumb_chain( { :controller => 'dashboard', :action => 'index' } ).collect{|c| c.url}

		assert_equal [{ :controller => 'users', :action => 'index' },{ :controller => 'dashboard', :action => 'index' }], @crumbs.crumb_chain( { :controller => 'users', :action => 'index' } ).collect{|c| c.url}
	end

	def test_view_controller
		# This is stuff you make in your controller prior to rendering a view

		# The controller will always have these specified in the view
		@controller.request.controller_name = 'users'
		@controller.request.action_name = 'show'
		# This is to trick the tests into thinking it's a view with a controller attached to it

		@controller.user = User.new
		@controller.user.name = 'Mike'

		assert_equal 'About: Mike', cw_bread_crumbs_title(@controller)

		assert_equal ['Dashboard','Users','About: Mike'], cw_bread_crumbs_chain(@controller).reverse.collect{|c| c.title(@controller)}
	end

	def test_custom_options
		# allows us to cram whatever we want into the crumb
		crumb = @crumbs.crumb_chain( { :controller => 'users', :action => 'list' }, 1 ).first
		assert_equal 'Users', crumb.title(nil)
		assert crumb.options.has_key?(:custom)
		crumb = @crumbs.crumb_chain( { :controller => 'users', :action => 'show' }, 1 ).first
		assert !crumb.options.has_key?(:custom)
	end

	def test_scaffold_crumb_maker
		# OK... I'm lazy. It tests the anime and manga controllers for all the scaffold stuff
		%w(animes mangas).each do |controller|
			%w(edit update destroy new create).each do |action|
				assert_equal [{ :controller => controller, :action => action },{ :controller => controller, :action => 'show' },{ :controller => controller, :action => 'list' },{ :controller => 'dashboard', :action => 'index' }], @crumbs.crumb_chain( { :controller => controller, :action => action } ).collect{|c| c.url}
			end
		end
		# Just to prove it's not making it up
		assert_equal [], @crumbs.crumb_chain( { :controller => 'illnesses', :action => 'list' } ).collect{|c| c.url}
	end

	def test_aliasing
		assert_equal @crumbs.crumb_chain( { :controller => 'books', :action => 'new' } ).collect{|c| c.url}, @crumbs.crumb_chain( { :controller => 'books', :action => 'create' } ).collect{|c| c.url}
		assert_equal [{:controller => 'books', :action => 'create'}], @crumbs.crumb_chain( { :controller => 'books', :action => 'new' }, 1 ).first.aliases

		assert_equal @crumbs.crumb_chain( { :controller => 'users', :action => 'edit' } ).collect{|c|c.url}, @crumbs.crumb_chain( { :controller => 'users', :action => 'update' } ).collect{|c| c.url}
		assert_equal [{:controller => 'users', :action => 'update'}], @crumbs.crumb_chain( { :controller => 'users', :action => 'edit' }, 1 ).first.aliases
	end

end # BreadCrumbTest
