module CW
module ScheduledVersion

	module Migration
		def self.included(base)
			base.extend(ClassMethods)
		end


		module ClassMethods

			def add_stub_fields( stub_klass_name )
				add_column stub_klass_name.constantize.table_name, stub_klass_name.constantize.scheduled_version_combine_column_name_and_prefix( :current_version_hint_id ), :integer
				add_column stub_klass_name.constantize.table_name, stub_klass_name.constantize.scheduled_version_combine_column_name_and_prefix( :current_version_hint_expires_at ), :timestamp
			end

			def remove_stub_fields( stub_klass_name )
				remove_column stub_klass_name.constantize.table_name, stub_klass_name.constantize.scheduled_version_combine_column_name_and_prefix( :current_version_hint_id )
				remove_column stub_klass_name.constantize.table_name, stub_klass_name.constantize.scheduled_version_combine_column_name_and_prefix( :current_version_hint_expires_at )
			end

			def create_scheduled_version_table( table_name, &block )
				create_table table_name do |t|
					t.column :exclusivity_id, :integer, :null => false
					t.column :version_id, :integer, :null => false
					t.column :cw_mu_ex_date_range_id, :integer, :null => false
					t.column :created_at, :timestamp, :null => false
					yield(t) if block_given?
				end
				add_index table_name, [:exclusivity_id, :version_id, :cw_mu_ex_date_range_id], :unique => true
			end

		end #ClassMethods

	end #Migration

end #ScheduledVersion
end # CW
