module CW
module BreadCrumbs
module Controller
module BreadCrumbs


class CrumbCycleError < StandardError
	attr :url
	def initialize( u )
		@url = u
	end
	def to_s
		"Crumb creates a cycle: '#{@url.inspect}'. Make sure you don't specify the same crumb twice!"
	end
end
class CrumbMissingError < StandardError
	attr :url
	def initialize( u )
		@url = u
	end
	def to_s
		"Crumb for url: '#{@url.inspect}' is missing. Did you define it? map.crumb( #{@url.inspect}, title )"
	end
end


=begin

The Crumbs is where all the Bread Crumbs are defined and mapped

All crumbs are uniquely defined with a URL

=end
class Crumbs

=begin
This is modelled after the ActionController Routes mapper. The idea is you define you crumb heirarchy at application start inside an initializer. You then render page titles and a bread-crumb list for page renders in your layouts/views respectively.

In an initializer, be sure to include the CW::BreadCrumbs::Controller in your ActionController.

Shortly thereafter, start mapping the bread-crumbs.

# includes the helpers, you don't HAVE to include this, you can roll your own if you'd like
ActionController.send(:include, CW::BreadCrumbs::Controller) # You kinda need this to use these bread crumbs
ActionController::BreadCrumbs::Crumbs.draw do |map|
	map.c( { :controller => 'dashboard', :action => 'index' }, 'Dashboard' ) { |d|
		d.c( { :controller => 'users', :action => 'index' }, 'User Dash' ) # my parent is the dashboard
		d.c( { :controller => 'users', :action => 'list' }, 'Users' ) { |u| # my parent is the dashboard
			u.c( { :action => 'show' }, Proc.new{|controller| 'About: ' + controller.get_instance_variable(:@user).name } ) { |u|
				u.c( { :action => 'edit' }, Proc.new{|controller| 'Change: ' + controller.get_instance_variable(:@user).name } ) # I'm a dynamically generated title ^_^
			}
		}
		d.c( { :controller => 'books', :action => 'list' }, 'Books' ) { |b| # my parent is the dashboard
			b.c( { :action => 'show' }, Proc.new{ |controller| controller.get_instance_variable(:@book).title } ) { |b|
				b.c( { :action => 'edit' }, 'Edit' )
				b.alias( :action => 'update' )
				b.c( { :action => 'new' }, 'New' )
				b.alias( :action => 'create' )
				b.c( { :action => 'destroy' }, 'Destroy' )
			}
		}
		d.c( { :controller => 'animes', :action => 'list' }, 'Animes' ) { |a| # my parent is the dashboard
			a.scaffold # Creates a bread crumb chain identical similar to Books, but uses no aliases.
		}
		d.c( { :controller => 'mangas', :action => 'list' }, 'Mangas' ) { |a| # my parent is the dashboard
			a.scaffold # Creates a bread crumb chain identical to the books one above, but for mangas
		}
	}
end

class ApplicationController
	helper CW::BreadCrumbs::ViewHelper
	[...] #your code here
end

For performance reasons, we cannot evaluate every path here for a match for breadcrumb selection and generation. I suppose a regexp would be better, but this is faster and most of the time, it's a numberic ID anyway. Therefore, all pages require both a controller and an action, minimum. There is a short cut, though. If you omit the controller, the parent's controller is used automatically. You MUST specify an action, however. I don't stop you if you don't, but your routes need to be configured without actions if you do this or your breadcrumbs won't show up.

So, the big deal is that we have acyclic chains going backward to either a top-level or the crumb has no parent (it is a top-level). I do mean chain and I do mean acyclic. This chain is constructed automatically by way of the syntax of specifying the crumbs. Each block contains crumbs that are below the parent crumb. This way, not only is it a breeze to specify your crumbs, but this also lets you skip specifying the controller and parent and automatically creates a backward link to contstruct a crumb back-link list.

This BreadCrumbs class will be initiailized at the launch of your applicaiton. It will remain in memory. It is a hash based on the crumb's URL ({:controller => '', :action => ''}). Only when a breadcrumb is requested will it be looked up and populated. By populated I mean that the view function will be called and you can set whatever you need to set. Typically, I needed this for creating pagination for a particular crumb, but it could be used to set any variable you need to generate for the actual display of the bread crumb. Remember, the whole point of this is to make your users' lives better without ruining yours; so, don't go crazy.

Aliases are provided for certain actions like new <-> create, and edit <-> update. Though they're separate actions, the new and edit methods are the "real" ones while create and update are the phantom actions that don't render directly to a view of their same name and require a POST method (and shouldn't be linked to directly). The alias method lets you link up a URL pattern to any crumb you like (based on another crumb pattern) but will assume you mean the last entered crumb if you only specify one url pattern.

=end
	def self.draw
		@@bakery = {}
		append do |batch|
			yield batch
		end
		@@bakery
	end

# Append
#
# Same as with .draw, but lets you append to the crumbs instead of overwriting them
	def self.append
		batch = CrumbBatch.new
		yield batch
		batch.add_to_bakery( self )
		self
	end


=begin
Test if creates a cycle

Tests the from and to to see if they point to themselves. If not, will test a existing chains to see if a cycle would be created by linking the two nodes. As we're building a directional graph, the order DOES matter.

Arguments:

	from: (Hash) of the URL for the Crumb
	to: (Hash) of the URL for the same or another Crumb as from

Returns:

	(boolean): true if a cycle would be created by adding this link (or connecting these nodes), false if no cycle would be created and it's OK to link them up safely.
=end
	def self.would_create_cycle?( from, to )
		# links to ourself is a cycle
		return true if from.eql?(to)
		# The destination doesn't exist anywhere so adding this cannot create a cycle
		return false unless @@bakery.has_key?(to)
		chain = @@bakery[to]
		until chain.nil?
			return true if chain.parent_url.eql?(from)
			# get the next in the chain
			chain = @@bakery[chain.parent_url]
		end
		return false
	end


	def self.add_crumb( crumb )
		raise CrumbCycleError.new(crumb.url) if crumb.parent_url and crumb.parent_url.eql?(crumb.url)
		raise CrumbCycleError.new if crumb.parent_url and would_create_cycle?( crumb.url, crumb.parent_url )
		@@bakery[crumb.url] = crumb
		self
	end

	def self.alias_crumb( crumb, as )
		raise CrumbCycleError.new(as) if crumb.parent_url and crumb.parent_url.eql?(as)
		raise CrumbCycleError.new if crumb.parent_url and would_create_cycle?( as, crumb.parent_url )
		# tell the crumb that it's getting a reference
		crumb.notify_of_alias( as )
		@@bakery[as] = crumb
		self
	end



=begin
Gets the complete chain of bread crumbs starting from the given start point. Array will always contain the crumb for the look-up value

Arguments:

	from_url: (Hash) of the url for the crumb to start. This is usually the page you're on, presently.
	limit: (Integer,optional) maximum number of back-links to return

Raises:

	CrumbMissingError if the crumb corresponding to the existing link does not exist (You specified a connection, but didn't specify the crumb that goes with it)

Returns:

	(Array) of Crumbs, in order starting from the current page and linking backward to the parent crumbs
=end
	def self.crumb_chain( from_url, limit = nil )
		ret = []
		link = @@bakery[from_url]
		# Cycle through the chain until we exhaust the chain
		while !link.nil? and ( limit.nil? or ( ret.size < limit ) )
			ret << link.url
			if link.parent_url
				link = @@bakery[link.parent_url]
			else
				break
			end
		end
		r = []
		ret.each do |x|
			t = @@bakery[x]
			raise CrumbMissingError.new( x ) if t.nil?
			r << t
		end
		return r
	end

	def self.[]( url )
		r = @@bakery[url]
		raise CrumbMissingError.new( url ) if r.nil?
		r
	end

end # Crumbs


# Crumb
#
# Data representation of a BreadCrumb node (page)
#
# The URL is required to link up the crumbs to each other. Indeed, it's the primary identification component for every crumb. Crumbs may have only 1 URL with which they are associated.
#
# The title is the title of the page. The crumb not only can tell how to build the crumb chain, but can also be used to set the page's title. This is also used to set the title for the crumb in the bread-crumb navigation. If you specify a proc, this will be evaulated when the crumb title is printed and can, therefore, represent arbitrary data. It is recommended that, for simplicity and MVC separation, that you set the title of the page in the controller and reference it here using the instance variable you'll name it in every controller. For example, if you set @title in your controller to the page title in all your controllers, you should then specify Proc.new{|controller| controller.instance_variable_get('@title')} in your crumb declarations
#
class Crumb
	attr_reader :url, :title_or_proc, :options, :aliases
	attr_accessor :parent_url

	def initialize( url, title_or_proc, options = {}, optional_proc = nil, parent_url = nil )
		@url = url # this must exist and must not be dependent on state
		# we cannot evaluation a proc now, only upon lookup within the controller's context
		# this also means
		@title_or_proc = title_or_proc
		@parent_url = parent_url
		@options = options
		@aliases = []
	end

	def title( controller )
		case @title_or_proc.class.name
			when 'String'
				@title_or_proc
			else
				@title_or_proc.call( controller )
		end
	end

	def notify_of_alias( a )
		@aliases << a
	end

end


# Groups Crumbs on a common level
class CrumbBatch
	attr_reader :batch
	def initialize
		@batch = []
	end

=begin
Actually adds a crumb to the heirarchy.

Arguments:
	url: (Hash) containing the URL map, usually of the form: {:action => '', :controller}.
	title: (String|Proc{|controller|} that will generate the page title, and indeed the breadcrumb entry for this crumb (if you want to use the helpers)
	options: (Hash) containing anything you want. You can pull this out later using the helpers or by accessing the completed bakery from, say, your views, later.
=end
	def crumb( url, title, options = {} )
		@batch << { :crumb => Crumb.new( url, title, options ), :children => nil }
		if block_given?
			b = CrumbBatch.new
			yield b
			@batch.last[:children] = b
		end
	end
	alias :c :crumb
	alias :push :crumb

=begin
Makes a URL alias to an existing crumb. Alias source -> destination.

Arguments:
	url: (Hash) containing the alias to the last crumb added with "crumb" (above) if optional_to_url is missing/nil. If it's specified, this is still the URL that will identify this crumb alias (source mapping).
	optional_to_url: (Hash, optional) pointing to the crumb the url will alias. Thsis is the destination mapping
=end
	def alias( url, optional_to_url = nil )
		# If optional_to_url is nil, use the last inputted URL
		if optional_to_url
			@batch << { :alias => url, :to => optional_to_url }
		else
			raise "Tried to add an alias without an explicit source when no sibling aliases defined" if @batch.empty?
			last = @batch.last
			if last.has_key?(:crumb) # is a crumb
				@batch << { :alias => url, :to => last[:crumb].url }
			else
				@batch << { :alias => url, :to => last[:to] }
			end
		end
	end


=begin
Creates crumbs for scaffold actions

Calling this without arguments will create the following crumbs:

* New
* Show
* Edit
* Update
* Destroy

This is equivalent to calling:

c.c( { :action => 'show' }, Proc.new{ |controller| 'Show' } ) { |c|
	c.c( { :action => 'edit' }, 'Edit' )
	c.c( { :action => 'new' }, 'New' )
	c.c( { :action => 'destroy' }, 'Destroy' )
	c.c( { :action => 'update' }, 'Update' )
	c.c( { :action => 'show' }, 'Show' )
}
=end
	def scaffold( what = {} )
		default = { :new => { :action => 'new', :title => 'New' }, :create => { :action => 'create', :title => 'Create' }, :edit => { :action => 'edit', :title => 'Edit' }, :update => { :action => 'update', :title => 'Update' }, :destroy => { :action => 'destroy', :title => 'Destroy' }, :show => { :action => 'show', :title => 'Show' } }
		what = default.merge( what )
		if what.has_key?(:show)
			crumb( { :action => what[:show][:action] }, what[:show][:title] ) do |c|
				what.reject{|k,v| k.eql?(:show) }.each_pair do |k,v|
					c.crumb( { :action => v[:action] }, v[:title] )
				end
			end
		else
			what.each_pair do |k,v|
				crumb( { :action => v[:action] }, v[:title] )
			end
		end
	end

	def add_to_bakery( bakery, parent = nil )
		@batch.each do |c|
			if c.has_key?(:crumb)
				# REAL CRUMB
				if parent
					c[:crumb].parent_url = parent.url
					c[:crumb].url.merge!( { :controller => parent.url[:controller] } ) unless c[:crumb].url.has_key?(:controller)
				end
				bakery.add_crumb( c[:crumb] )
				# we have children, add them to the bakery recursively with this crumb as the parent
				if c[:children]
					c[:children].add_to_bakery( bakery, c[:crumb] )
				end
			else
				#ALIAS
				bakery.alias_crumb( bakery[c[:to]], bakery[c[:to]].url.merge(c[:alias]) )
			end
		end
	end

end # Batch

end # BreadCrumbs
end # Controller
end # BreadCrumbs
end # CW
