class SearchFormDrop < BaseDrop

	def initialize( controller, options = {} )
		@controller = controller
		@options = options
	end

	def form
		@controller.send( :render, { :partial => 'search/form', :locals => { :skip_label => true } } )
	end

end
