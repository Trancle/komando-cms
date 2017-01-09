require 'test/unit'
require 'cw_action_nav'
require 'rubygems'
gem 'actionpack', '=2.3.14'
require 'active_support'
require 'active_support/test_case'
require 'action_controller'
require 'action_controller/test_process'

ActionController::Base.prepend_view_path File.dirname(__FILE__)
class TestController < ActionController::Base
	helper CW::ActionNav::Controller
	helper CW::ActionNav::View

	def two_sections_with_five_links
		@nav = CW::ActionNav::Controller::Base.new.section( 'First' ) { |s|
			s.link( 'edit', { :action => 'edit', :id => 4 } )
			s.link( 'undo', { :action => 'undo', :id => 4 } )
		}.section( 'Second' ) { |s|
			s.link( 'delete', { :action => 'delete_confirm', :id => 4 } )
			s.link( 'hide', { :action => 'hide', :id => 4 } )
			s.link( 'explode', { :action => 'explode', :id => 4 } )
		}
		render :action => 'views/plain'
	end

	def nested_sections
		@nav = CW::ActionNav::Controller::Base.new.section( 'First' ) { |s|
			s.link( 'edit', { :action => 'edit', :id => 4 } )
			s.link( 'undo', { :action => 'undo', :id => 4 } )
			s.section( 'Second' ) { |s|
				s.link( 'delete', { :action => 'delete_confirm', :id => 4 } )
				s.link( 'hide', { :action => 'hide', :id => 4 } )
				s.link( 'explode', { :action => 'explode', :id => 4 } )
			}
		}
		render :action => 'views/plain'
	end

	def with_text
		@nav = CW::ActionNav::Controller::Base.new.section( 'First' ) { |s|
			s.link( 'edit', { :action => 'edit', :id => 4 } )
			s.html( 'Plain HTML' )
		}
		render :action => 'views/plain'
	end

end
ActionController::Routing::Routes.draw do |map|
        map.connect ':controller/:action/:id'
end

class CwActionNavTest < ActionController::TestCase
	tests TestController

	def setup
	end
	def teardown
	end

	def test_basic
		get :two_sections_with_five_links
		assert_response :success

		nav = assigns(:nav)
		assert_equal '<ul><li class="section"><span class="section">First</span><ul><li class="link"><a href="/test/edit/4">edit</a></li><li class="link"><a href="/test/undo/4">undo</a></li></ul></li><li class="section"><span class="section">Second</span><ul><li class="link"><a href="/test/delete_confirm/4">delete</a></li><li class="link"><a href="/test/hide/4">hide</a></li><li class="link"><a href="/test/explode/4">explode</a></li></ul></li></ul>'+ "\n", @response.body
	end

	def test_nested_sections
		get :nested_sections
		assert_response :success

		nav = assigns(:nav)
		assert_equal '<ul><li class="section"><span class="section">First</span><ul><li class="link"><a href="/test/edit/4">edit</a></li><li class="link"><a href="/test/undo/4">undo</a></li><li class="section"><span class="section">Second</span><ul><li class="link"><a href="/test/delete_confirm/4">delete</a></li><li class="link"><a href="/test/hide/4">hide</a></li><li class="link"><a href="/test/explode/4">explode</a></li></ul></li></ul></li></ul>'+ "\n", @response.body
	end

	def test_with_text
		get :with_text
		assert_response :success

		nav = assigns(:nav)
		assert_equal '<ul><li class="section"><span class="section">First</span><ul><li class="link"><a href="/test/edit/4">edit</a></li><li class="inner_html">Plain HTML</li></ul></li></ul>'+ "\n", @response.body
	end



end
