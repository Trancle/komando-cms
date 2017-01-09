/* Base mode schema class */
var CWActiveRecordSchema = Class.create( {
			initialize: function( sch ) {
				sch = $H(sch);
				if( !this.is_hash_valid_schema( sch ) ) {
					throw "Schema is not valid";
				} else {
					this.schema = sch;
				}
			},
			valid_schema_types: function() {
				return ["string", "number", "date", "boolean"];
			},
			is_hash_valid_schema: function( h ) {
				var me = this;
				return !h.detect( function(e) {
						var k = e[0];
						var v = e[1]
						return !( me.valid_schema_types().include( v ) );
					} );
			}
		} );

/* Base model class */
var CWActiveRecord = Class.create( {
			initialize: function( attributes ) {
				// initialize the attributes list
				if( attributs == null )  { attributes = new Hash(); }
				this.attributes = $H(attributes);
			}
		} );
