module CW
module ActionNav
module Controller

class DefComponent
	def each_at_level( level = 1, &block )
		nil
	end
end

class InnerHtml < DefComponent
	attr_reader :inner_html
	def initialize( inner_html )
		@inner_html = inner_html
	end
	def to_s
		@inner_html
	end
	def each_at_level( level = 1, &block )
		yield self, level
	end
end # InnerHtml

class Link < DefComponent
	attr_accessor :inner_html, :url_options, :html_options
	def initialize( inner_html, url_options, html_options = nil )
		@inner_html = InnerHtml.new inner_html
		@url_options = url_options
		@html_options = html_options
	end
	def each_at_level( level = 1, &block )
		yield self, level
	end
end # Link


class Button < DefComponent
	attr_accessor :inner_html, :url_options, :html_options
	def initialize( inner_html, url_options, html_options = nil )
		@inner_html = InnerHtml.new inner_html
		@url_options = url_options
		@html_options = html_options
	end
	def each_at_level( level = 1, &block )
		yield self, level
	end
end # Button

# Pseudo Element: Pop
#
# Indicates that we just popped up a level. Contains the level we just came from
class Pop < DefComponent
	attr_reader :from
	def initialize( from )
		@from = from
	end
	def to_s
		'' #be invisible
	end
end # Pop

class Section < DefComponent
	attr_accessor :title, :programmatic_title, :links
	def initialize( title, programmatic = nil )
		@title = InnerHtml.new title
		@programmatic_title = programmatic
		@programmatic_title = title.underscore if programmatic.nil?
		@navigation = []
	end

	def link( inner_html, url_options, html_options = {} )
		@navigation << Link.new( inner_html, url_options, html_options )
		self
	end

	def button( inner_html, url_options, http_options = {} )
		@navigation << Button.new( inner_html, url_options, http_options )
		self
	end

	def section( name, programmatic = nil )
		s = Section.new name
		yield( s )
		@navigation << s
		self
	end

	def html( text )
		@navigation << InnerHtml.new( text )
	end

	def each_at_level( level = 1, &block )
		block.call self, level
		@navigation.each do |n|
			n.each_at_level( level + 1, &block )
		end
		block.call Pop.new( self ), level # inform our renderer that we just came from no where
	end

	def empty?
		@navigation.empty?
	end
end # Section

# Defines an action Navigation
#
# Allows one to create a listing of actions that can be later rendered in views. The syntax is:
#
# @page_actions = CW::ActionNav::Controller::Def.new.section( 'View' ) {|s|
#		s.link( 'List', { :action => 'list' } )
#	}.section( 'Delete' ) { |s|
#		s.link( 'Random', { :action => 'delete_random' } )
#		s.link( 'All', { :action => 'delete_all' } )
#	}
#
# And you could, later, render this from the above:
#	<ul>
#		<li>View<ul>
#			<li><a href="/controller/list">List</a></li>
#		</ul></li>
#		<li>Delete<ul>
#			<li><a href="/controller/delete_random">Random</a></li>
#			<li><a href="/controller/delete_all">All</a></li>
#		</ul></li>
#	</ul>
#
# The notion is to strip away having to render the navigation in the view. Here, we'd be able to subclass and strip out or disable links if the user isn't authorized to click on those links. I'm not saying don't enforce the permissions elsewhere, but it's nice to know what you can and cannot access.
#
# Additionally, we'd be able to have a uniform method of rendering this and therefore, could template this render out.
class Base
	
	attr_reader :navigation

	def initialize
		@navigation = []
	end

	def section( name, programmatic = nil )
		s = Section.new name
		yield( s )
		@navigation << s
		self
	end

	def link( inner_html, url_options, http_options = {} )
		@navigation << Link.new( inner_html, url_options, http_options )
		self
	end

	def button( inner_html, url_options, http_options = {} )
		@navigation << Button.new( inner_html, url_options, http_options )
		self
	end

	def empty?
		navigation.empty?
	end

	def each_at_level( level = 1, &block )
		navigation.each do |nav|
			nav.each_at_level( level + 1, &block )
		end
	end

end # Base

end # Controller

module View

def render_actions( view, action_definition, options = {}, &block )

	s = view.tag( 'ul', options, true )
	action_definition.each_at_level do |item,level|
		case item.class.name
			when 'CW::ActionNav::Controller::Link'
				s += '<li class="link">'
				if block_given?
					s += block.call( item, level )
				else
					s += view.link_to( item.inner_html, item.url_options, item.html_options )
				end
				s += '</li>'
			when 'CW::ActionNav::Controller::Button'
				s += '<li class="button">'
				if block_given?
					s += block.call( item, level )
				else
					s += view.button_to( item.inner_html, item.url_options, item.html_options )
				end
				s += '</li>'
			when 'CW::ActionNav::Controller::Section'
				s += '<li class="section"><span class="section">'
				if block_given?
					s += block.call( item, level )
				else
					s += h(item.title)
				end
				s += '</span>'

				if item.empty?
					s += '</li>'
				else
					s += '<ul>'
				end
			when 'CW::ActionNav::Controller::InnerHtml'
				s += '<li class="inner_html">'
				if block_given?
					s += block.call( item, level )
				else
					s += item.inner_html
				end
				s += '</li>'
			when 'CW::ActionNav::Controller::Pop'
#s += 'POP'
				case item.from.class.name
					when 'CW::ActionNav::Controller::Section'
						unless item.from.empty?
							s += '</ul></li>'
						end
				else
					raise ArgumentError.new( "Tried to Pop from Def class named: #{item.class.name}" )
				end
		else
			raise ArgumentError.new( "Unrecognized Def class named: #{item.class.name}" )
		end
	end
	s += '</ul>'
	s
end

end # View

end # ActionNav
end # CW
