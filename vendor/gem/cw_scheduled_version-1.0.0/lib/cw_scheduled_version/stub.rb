module CW
module ScheduledVersion
	module Stub
		def self.included(base)
			base.extend(ClassMethods)

			base.has_many :scheduled_versions, :class_name => base.scheduled_version_klass.name, :foreign_key => 'exclusivity_id'
		end

		# Current Version
		# Gets the version that is running during the specified time (NOW by default)
		def scheduled_version_current( thetime = Time.now.utc, update_hint = false, force = false )
			# check the hint, if it exists.
			# if not exists or exists but is expired, try to look up the current version
			# on success, set the hint and expiration date to the curent version and set expiration to end of current range
	    # if exists and is not expired, query the version in the hint.
		  # if it doesn't exist, return nil and leave hint and expiration nil

			# nil hints indicate that there is no data. It does not indicate expiration or initial population. To force a hint cache clear: specify the expires at date to be now. Next request will update the hint with the live data


			# if nil, not set: otherwise will be a #
			expiration = self.send( self.class.scheduled_version_combine_column_name_and_prefix( :current_version_hint_expires_at ) )
			hint_id = self.send( self.class.scheduled_version_combine_column_name_and_prefix( :current_version_hint_id ) )
			# both are nil, meaning no expiration and no data: no data in DB to show!
			return nil if hint_id.nil? and expiration.nil? and !force

			# now, hint or expiration exists

			vmid = nil
			# expiration specified
			if !expiration.nil? or force
				if force or (expiration <= thetime)
					# hint is now expired, look up the new hint
					vmid, expiration = scheduled_version_find_current_version_id_and_expiry_at( thetime )

					if update_hint
						self.send( self.class.scheduled_version_combine_column_name_and_prefix( :current_version_hint_expires_at ).to_s + '=', expiration )
						self.send( self.class.scheduled_version_combine_column_name_and_prefix( :current_version_hint_id ).to_s + '=', vmid )
						self.save
					end
				else expiration > thetime
					# hint is still valid
					vmid = self.send( self.class.scheduled_version_combine_column_name_and_prefix( :current_version_hint_id ) )
				end
			else
				# no expiration date, just use the hint, nil or not
				vmid = self.send( self.class.scheduled_version_combine_column_name_and_prefix( :current_version_hint_id ) )
			end


			# look up the Version model unless id is nil (nothing to show)
			return self.class.versioned_model_klass.find( vmid ) unless vmid.nil?
			return nil
		end

		# like current_version, but skips hints and does the DB query direct also allows for time to be specified
		def scheduled_version_find_current_version_id_and_expiry_at( thetime )
			vmk = self.class.versioned_model_klass
			drk = self.class.scheduled_version_cw_mu_ex_date_range_range_klass
			drsk = self.class.scheduled_version_cw_mu_ex_date_range_set_klass
			svk = self.class.scheduled_version_klass
			res = vmk.find(:first, :select => "#{vmk.table_name}.id AS vmid, #{drk.table_name}.end_at AS expires_at", :joins => "INNER JOIN #{svk.table_name} ON #{svk.table_name}.version_id = #{vmk.table_name}.id INNER JOIN #{drk.table_name} ON #{drk.table_name}.id = #{svk.table_name}.cw_mu_ex_date_range_id", :conditions => drsk.conditions_for_range_including( drk.table_name, self.id, thetime ) )

			vmid = nil
			expires_at = nil
			if res
				vmid = res.vmid
				expires_at = res.expires_at
			end

			# nothing current, let's look up for how long: get the next start date
			if vmid.nil?
				next_range = drsk.find_next_range( self.id, thetime )
				# set expiration to the next start date, if exists
				expires_at = next_range.start_at unless next_range.nil?
			end

			# vmid = the ID of the version model that is currently live at thetime, NIL if nothing is live
			# expires_at = time vmid should no longer be the current version, NIL if no expiration date
			return vmid, expires_at
		end

		def scheduled_version_at_time( t )
			# finds the version for the time requested
			vmk = self.class.versioned_model_klass
			vmk.find(:first, self.class.scheduled_version_at_time_sql_hash( self.class, t ) )
		end

		def scheduled_version_schedule_version_with_range( version, r, t = Time.now.utc )
			drk = self.class.scheduled_version_cw_mu_ex_date_range_range_klass
			actions = {:new => [], :update => [], :delete => []}
			# set the exclusivity_id
			exid = version.send( version.class.versioning_combine_column_name_and_prefix( :stub_id ) )
			# Exclusivity_id is enforced!
			unless r.exclusivity_id.eql?exid
				r.exclusivity_id = exid 
			end

			splits = {}

			self.class.transaction do
				# DB fetch for overlapped ranges, we need them all for this
				affected_ranges = r.overlaps
				# for each range, we'll subtract off the part that overlaps
				res = nil
				affected_ranges.each do |affected_range|
					res = affected_range - r
					# splits an old range
					unless res[:split].nil?
						splits[affected_range] = res[:split]
						actions[:update] << res[:split][:old] # need to update the old version
					end
					# cuts an old range
					actions[:update] << res[:update] unless res[:update].nil?
					# deletes an old range
					unless res[:delete].nil?
						actions[:delete] << res[:delete]
						# scheduled version automatically cleaned up by associtation in the date range class
					end
				end
				# see if the current range will be changed
				current_range = drk.find_first_containing( self.id, t )
				changed_current_version = false
				unless current_range.nil?
					changed_current_version = !( actions[:delete] | actions[:update] ).select{|i| i.id.eql?current_range.id }.empty?
				end

				# update the affected ranges:
				actions[:delete].each do |d|
					d.destroy
				end
				actions[:update].each do |u|
						u.save!
				end

				# process the splits: must be done here after what needs to be deleted gets deleted
				splits.each_pair do |affected_range,res|
					# add a schedule to this range
					# lookup the current range associated with this date range
					v = version.class.scheduled_version_klass.find( :first, :conditions => ['cw_mu_ex_date_range_id = ?',(affected_range.id)], :readonly => true )
					sv = version.class.scheduled_version_klass.new
					sv.version_id = v.version_id
					sv.exclusivity_id = v.exclusivity_id
# problem is, if there is overlap, we haven't removed it yet... need to save this step for later
					res[:new].save! #Create an ID for the new range
					sv.cw_mu_ex_date_range_id = res[:new].id
					sv.save!
				end


				# save the new range
				r.save!
				# create a new version-LINK-range
				sv = version.class.scheduled_version_klass.new
				sv.exclusivity_id = r.exclusivity_id
				sv.version_id = version.id
				sv.cw_mu_ex_date_range_id = r.id
				sv.save!

				# need to update the hint in the stub class
				# if we changed the current date:
				# The only way this changes is if we added a date over the current
				if changed_current_version or r.includes?( t )
					self.scheduled_version_clear_hint( t )
					# updated current version: update the database to ensure hints work correctly
					self.save!
				end

			end
			r
		end

		def scheduled_version_clear_hint( t = Time.now.utc )
			# clear the hint
			self.send( self.class.scheduled_version_combine_column_name_and_prefix( :current_version_hint_id ).to_s + '=', nil )
			# set expiration to now, or whenever specified above
			self.send( self.class.scheduled_version_combine_column_name_and_prefix( :current_version_hint_expires_at ).to_s + '=', t )
		end

		def scheduled_version_unschedule( date_range )

			self.class.transaction do
				save_yourself = false
				if date_range.scheduled_version.version.id.eql?( self.send( self.class.scheduled_version_combine_column_name_and_prefix( :current_version_hint_id ) ) )
					self.scheduled_version_clear_hint
					save_yourself = true
				end

				date_range.destroy
				
				self.save! if save_yourself
			end

		end


		module ClassMethods
			def scheduled_version_specific_columns
				[:current_version_hint_id,:current_version_hint_expires_at].collect{|x| versioning_combine_column_name_and_prefix(x) }
			end
			def default_scheduled_version_specific_columns_prefix
				'version_'
			end
			def scheduled_version_specific_columns_prefix
				default_scheduled_version_specific_columns_prefix
			end
			def scheduled_version_combine_column_name_and_prefix( name )
				(scheduled_version_specific_columns_prefix + name.to_s).to_sym
			end
#			def scheduled_version_cw_mu_ex_date_range_set_klass
#				raise NotImplementedError.new( "You must override scheduled_version_cw_mu_ex_date_range_set_klass class method in #{self.name} and specify the date range klass string name (the one that includes  CW::MuExDateRange::Set)" )
#			end
#			def scheduled_version_cw_mu_ex_date_range_range_klass
#				raise NotImplementedError.new( "You must override scheduled_version_cw_mu_ex_date_range_range_klass class method in #{self.name} and specify the date range klass string name (the one that includes  CW::MuExDateRange::Range)" )
#			end
#			def scheduled_version_klass
#				raise NotImplementedError.new( "You must override scheduled_version_klass class method in #{self.name} and specify the string name of the Class that represents the scheduled version table (the one that includes CW::ScheduledVersion::Base)" )
#			end
#			def versioned_model_klass
#				raise NotImplementedError.new( "You must override versioned_model_klass class method in #{self.name} and specify the string name of the Class that represents the scheduled version versoned model table (the one that includes CW::ActsAs::Versioned::Versioned)" )
#			end

			def scheduled_version_find_current_stubs_options( t = Time.now.utc )
				drk = self.scheduled_version_cw_mu_ex_date_range_range_klass
				svk = self.scheduled_version_klass
				drsk = self.scheduled_version_cw_mu_ex_date_range_set_klass
				{ :select => "#{self.table_name}.*, #{drk.table_name}.end_at", :joins => "INNER JOIN #{svk.table_name} ON #{svk.table_name}.exclusivity_id = #{self.table_name}.id INNER JOIN #{drk.table_name} ON #{drk.table_name}.id = #{svk.table_name}.cw_mu_ex_date_range_id", :conditions => drsk.conditions_for_range_including( drk.table_name, nil, t ) }
			end


			def scheduled_version_at_time_sql_hash( klass, t )
				vmk = klass.versioned_model_klass
				drk = klass.scheduled_version_cw_mu_ex_date_range_range_klass
				svk = klass.scheduled_version_klass
				{ :select => "#{vmk.table_name}.*, #{drk.table_name}.end_at", :joins => "INNER JOIN #{svk.table_name} ON #{svk.table_name}.exclusivity_id = #{vmk.table_name}.stub_id INNER JOIN #{drk.table_name} ON #{drk.table_name}.exclusivity_id = #{svk.table_name}.exclusivity_id", :conditions => drk.conditions_for_range_including( drk.table_name, self.id, t ) }
			end



		end #ClassMethods
	end #Stub
end #ScheduledVersion
end #CW
