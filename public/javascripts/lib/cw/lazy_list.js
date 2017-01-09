/* Creates a lazy list as a loaded hash where items are loaded on a per-page basis, call-backs used to request more info */
var LazyList = Class.extend( {
initialize: function( options ) {
	this.list = new Hash();
	this.onRequestPageDelegate = options.onRequestPageDelegate;
},
clone: function() {
	var l = new LazyList( { "onRequestPageDelegate": this.onRequestPageDelegate } );
	this.list.each( function(e) {
		l.set( e.key, e.value );
	} );
	return l;
},
get: function( index ) {
	if( this.list.size() == 0 ) {
		if( !this.load_page(1) ) {
			return false;
		}
	}
	var p = this.predict_page( index );
	if( !this.has_page( p ) ) {
		/* doesn't have the page, load it */
		this.load_page(p);
	}
	/* still empty? NOTHING in the list */
	if( this.list.size() == 0 ) {
		return null;
	}
	/* has the page, return the item */
	if( this.list.get(p) == null ) return null;
	//alert( "Returning index: " + new String(index) );
	return this.list.get(p)[index%this.items_per_page()];
},
set: function( k, v ) {
	this.list.set( k, v );
},
items_loaded: function() {
	var c = 0;
	var me = this;
	this.list.keys().each( function(e) {
				c += me.list.get(e).length;
			} );
	return c;
},
pages_loaded: function() {
	return this.list.keys().size();
},
predict_page: function(index) {
	return Math.floor(index/this.items_per_page()) + 1;
},
has_page: function(page_num) {
	return this.list.get(page_num);
},
load_page: function(page_num) {
	var np = this.onRequestPageDelegate.onRequestPage( page_num );
	if( np != null ) {
		this.list.set(page_num,np);
		return true;
	}
	return false;
 },
get_range: function( start, end ) {
	var ret = [];
	var i = start;
	var t = null;
	//alert( "Getting range: [" + new String(start) + "," + new String(end) + "]" );
	for( ; i < end; i += 1 ) {
		t = this.get(i);
		if( t != null ) {
			ret.push( t );
		} else {
			// no more left!
			return ret;
		}
	}
	return ret;
},
items_per_page: function() {
	if( this.items_loaded() != 0 ) {
		// Look at the first page for items per page
		return this.list.get(1).length;
	}
	return 0;
},
inspect: function() {
	return "LazyList:<items_per_page:" + new String( this.items_per_page() ) + ";pages_loaded:" + new String( this.pages_loaded() ) + ";list:" + this.list.inspect() + ">";
}
});
