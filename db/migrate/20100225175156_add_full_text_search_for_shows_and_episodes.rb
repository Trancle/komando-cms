class AddFullTextSearchForShowsAndEpisodes < ActiveRecord::Migration
  def self.up
		# This is post-gresql specific

		# VECTORIZED COLUMN
		# Create the Text Search column in the objects, concatenating both the title and description:
unless connection.class.eql?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
		say 'Creating ts_index for show_versions and episode_versions'
		connection.execute( "ALTER TABLE show_versions ADD COLUMN ts_index tsvector;" )
		connection.execute(	"ALTER TABLE episode_versions ADD COLUMN ts_index tsvector;" )

		# TRIGGER: UPDATE VECTORIZED COLUMN
		# Create a trigger to populate these fields on update and create
		say 'Creating trigger for updates on show_versions and episode_versions'
		connection.execute( "CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON show_versions FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger( ts_index, 'pg_catalog.english', title, description );" )
		connection.execute( "CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON episode_versions FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger( ts_index, 'pg_catalog.english', title, description );" )

		# INDEX
		# Create an index to search on the vectorized column created above
		say 'Creating text searchable index (lightning fast searching) on show_versions and episode_versions'
		connection.execute( "CREATE INDEX show_versions_on_ts_index ON show_versions USING gin(ts_index);" ) 
		connection.execute( "CREATE INDEX episode_versions_on_ts_index ON episode_versions USING gin(ts_index);" )
		end

  end

  def self.down
		# remove indices
unless connection.class.eql?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
		connection.execute( "DROP INDEX episode_versions_on_ts_index" ) 
		connection.execute( "DROP INDEX show_versions_on_ts_index" )

		# remove trigger
		connection.execute( "DROP TRIGGER tsvectorupdate ON episode_versions" )
		connection.execute( "DROP TRIGGER tsvectorupdate ON show_versions" )

		# remove column
		remove_column :episode_versions, :ts_index
		remove_column :show_versions, :ts_index
		end

  end
end
