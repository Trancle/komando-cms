(function($) {
    var methods = {

        /*


Create a picker window by calling this method on a div.
<div id="picker"></div>
<script type="text/javascript">
$('#picker').picker_window( { listUri: '/path/to.json' } );
</script>

JSON format:
{
"items": [...],
"total_number_of_pages": total number of pages,
"total_number_of_items": total number of pages
}

items is the array of items on the page. You can control how you want this to be created by overridding:
onPaint. Otherwise, onPaint will simply assume that you're sending text.

Options:
         {
         perPage: 10,
         windowTitle: "Pick an item",
         instruction: "Click on the item to select it",
         current_page: 1,
         ajaxListUri: null,
         paginationParamKey: "page",
         totalListCount: null,
         currentPick: null,
	 extraData: {}, // empty. Data to append to the AJAX request, for whatever reason
         pageData: {}, // empty, nothing loaded,
         onPick: null, // user picked an item
         onCancel: null, // user didn't pick anything but window closed
         onShow: null, // user didn't pick anything but window closed
         onPaint: null
         onPaintItem: null,
         closeButtonText: 'X'
         }
         */
        init : function( options ) {
            $(this).data('picker_window', {
                perPage: 10,
                windowTitle: "Pick an item",
                instructions: "Click on the item to select it",
                current_page: 1,
                listUri: null,
                paginationParamKey: "page",
                totalListCount: null,
                currentPick: null,
		extraData: {},
                pageData: {}, // empty, nothing loaded,
                onPick: null, // user picked an item
                onCancel: null, // user didn't pick anything but window closed
                onShow: null, // user didn't pick anything but window closed
                onPaint: null,
                onPaintItem: null,
                closeButtonText: 'X',
                initialSelectedItemKey: null,
                selectedItemKeyToData: null
            } );
            $.extend( $(this).data('picker_window'), options );

            var me = $(this);
            // picker is initially invisible
            $(this).hide();

            // create picker close button
            var close = document.createElement('button');
            $(close).text($(this).data('picker_window').closeButtonText);
            $(close).addClass('picker-close');
            $(close).click( function(e) {
                e.preventDefault();
                me.picker_window('cancel');
            });
            $(this).append(close);

            // create picker title
            var title = document.createElement('h1');
            $(title).text($(this).data('picker_window').windowTitle);
            $(this).append(title);

            // create picker description
            var instructions = document.createElement('p');
            $(instructions).text($(this).data('picker_window').instructions);
            $(instructions).addClass('instructions');
            $(this).append(instructions);

            // Create picker navigation
            var nav = document.createElement('ul');
            $(nav).addClass('picker-pagination');

            // previous button
            var navel = document.createElement('li');
            var btn = document.createElement('button');
            $(btn).text('previous page');
            $(btn).addClass('previous');
            $(btn).click( function(e) {
                e.preventDefault();
                me.picker_window('go_previous_page');
            });
            $(nav).append(navel);
            $(navel).append(btn);

            // next button
            navel = document.createElement('li');
            btn = document.createElement('button');
            $(btn).text('next page');
            $(btn).addClass('next');
            $(btn).click( function(e) {
                e.preventDefault();
                me.picker_window('go_next_page');
            });
            $(nav).append(navel);
            $(navel).append(btn);

            navel = document.createElement('li');
	    $(navel).addClass('jump');
	    var input = document.createElement('input');
	    btn = document.createElement('button');
	    $(input).attr('type','text');
	    $(btn).click( function(e) {
		  e.preventDefault();
		  me.picker_window('go_page', parseInt( $(input).val() ) );
		} );
	    $(btn).text('go');
	    $(navel).append(input);
	    $(navel).append(btn);
	    $(nav).append(navel);

            navel = document.createElement('li');
	    $(navel).addClass('statistics');
	    // <li class="statistics">Page <span class="current-page-number">1</span> of <span class="total-page-number">50</span></li>
	    $(navel).html( 'Page <span class="current-page-number">1</span> of <span class="total-page-number">50</span>' );
	    $(nav).append(navel);

            $(this).append(nav);

            // Create the list
            var list = document.createElement('ul');
            $(list).addClass('picker-items');
            var item;
            for( var i = 0; i < $(this).data('picker_window').perPage; i++ ) {
                item = document.createElement('li');
                // initially invisible
                $(item).hide();
                // register click event
                $(item).click( function(e) {
                  me.picker_window('onPick', e.currentTarget );
                });
                $(list).append(item);
            }
            $(this).append(list);
        },
        show : function( ) {
            // See if data is loaded, if not, load it.
            $(this).picker_window('go_page',$(this).picker_window('current_page'));
            $(this).show();
            $(this).picker_window("onShow");
            return this;
        },
        cancel : function( ) {
            $(this).hide();
            $(this).picker_window("onCancel");
            return this;
        },

        // Paints the window with the data so that the picker system can work properly
        paint : function() {
            // can be overridden
            if( $(this).data("picker_window").onPaint !== null ) {
                // completely supplants all painting logic
                $(this).data("picker_window").onPaint( this );
            } else {
                // i marks the index of the elem we're editing
                // page is the data for this page as an array.
                var page = $(this).picker_window('page',$(this).picker_window('current_page'));
                // elem is the li handle that we're updating
                var me = $(this);
                $(this).find('.picker-items li').each( function(i,elem) {
                  if( i >= page.length ) {
                      // more items then we have in this page, hide the element
                      $(elem).hide();
                      $(elem).removeClass('selected');
                  } else {
                      // only paint the ones shown, makes sense, right?
                      $(elem).removeClass('selected');
                      if( page[i] === me.data('picker_window').currentPick ) {
                          $(elem).addClass('selected');
                      }

                      if( me.data("picker_window").onPaintItem !== null ) {
                          // completely supplants all painting logic
                          me.data("picker_window").onPaintItem( me, elem, i, page );
                      } else {
                          if( Object.prototype.toString.call( page[i] ) === '[object Array]' ) {
                              // if array is given:
                              // [KEY,VALUE] where key is a string you use to figure out the value and the VALUE is the value displayed to the user
                              $(elem).text(page[i][1]);
                          } else {
                              // just text
                              $(elem).text(page[i].toString());
                          }
                      }
                      $(elem).show();
                  }
                });



                $(this).picker_window('update_navigation');
            }
        },

        current_page : function() {
            return $(this).data('picker_window').current_page;
        },
	total_pages : function() {
	    return $(this).data('picker_window').totalListCount;
	},

        go_next_page : function() {
            if( $(this).picker_window('current_page') != $(this).data("picker_window").totalListCount ) {
                $(this).picker_window('go_page',$(this).picker_window('current_page') + 1);
            }
        },
        go_previous_page : function() {
            if( $(this).picker_window('current_page') != 1 ) {
                $(this).picker_window('go_page',$(this).picker_window('current_page') - 1);
            }
        },
        go_page : function( page_number ) {
          if( $(this).picker_window('page',page_number) !== null ) {
            // Page was loaded
            // set the page
            $(this).data('picker_window').current_page = page_number;
            // update the window
            $(this).picker_window('paint');
          }
        },
        page : function( page_number ) {
            if( $(this).data('picker_window').pageData[page_number] === undefined ) {
                $(this).picker_window('load_page',page_number);
                return $(this).data('picker_window').pageData[page_number];
            } else {
                return $(this).data('picker_window').pageData[page_number];
            }
        },

        update_navigation : function() {
          // updates the navigation based on the current page and total page data
          // previous button:
            if( $(this).picker_window('current_page') == 1 ) {
                // disable the previous button
                $(this).find('.picker-pagination .previous').addClass('disabled');
            } else {
                $(this).find('.picker-pagination .previous').removeClass('disabled');
            }
            if( $(this).picker_window('current_page') == $(this).data("picker_window").totalListCount ) {
                // disable the next button
                $(this).find('.picker-pagination .next').addClass('disabled');
            } else {
                $(this).find('.picker-pagination .next').removeClass('disabled');
            }

	    // update the current page number and total
            $(this).find('.picker-pagination .current-page-number').text( $(this).picker_window('current_page') );
	    $(this).find('.picker-pagination .total-page-number').text( $(this).picker_window('total_pages') );
        },



        load_page : function( page_number ) {
            var d = {};
            var me = $(this);
	    d = $.extend( $(this).data('picker_window').extraData, d );
            d[$(this).data('picker_window').paginationParamKey] = page_number;
            d['per_page'] = $(this).data('picker_window').perPage;
	    
            $.ajax( {
                url: $(this).data("picker_window").listUri,
                method: 'get',
                async: false, // We need to wait for the data to be ready
                data: d
            } ).success( function(data) {
                me.data("picker_window").totalListCount = data.total_number_of_pages;
                    me.data("picker_window").pageData[page_number] = data.items;
            }).error( function() {

            } );
            return $(this).picker_window('page', page_number);
        },




        // Let's whoever sets this callback know that the user picked an item and which item was picked.
        onPick : function( elem ) {
            var index = $(this).find('.picker-items li').index(elem);
            var page = $(this).picker_window('page',$(this).picker_window('current_page'));
            var data = page[index];
          // meant to be overridden
            if( $(this).data("picker_window").onPick !== null ) {
                $(this).data("picker_window").onPick( elem, index, data );
            }
            $(this).data('picker_window').currentPick = data;
            $(this).hide();
        },
        onCancel : function() {
            // meant to be overridden
            if( $(this).data("picker_window").onCancel !== null ) {
                $(this).data("picker_window").onCancel();
            }
        },
        onShow : function() {
            // meant to be overridden
            if( $(this).data("picker_window").onShow !== null ) {
                $(this).data("picker_window").onShow();
            }
        }
    };

    $.fn.picker_window = function( method ) {

        // Method calling logic
        if ( methods[method] ) {
            return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
        } else if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        } else {
            $.error( 'Method ' +  method + ' does not exist on jQuery.picker_window' );
        }

    };



})( jQuery );
