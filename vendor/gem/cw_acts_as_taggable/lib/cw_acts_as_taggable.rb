# CwActsAsTaggable
module CW
module ActsAs
module Taggable

module Base
	def self.included(base)
		base.extend(ClassMethods)
		base.validates_presence_of :tag
		base.validates_length_of :tag, :in => 1..64, :allow_nil => true
		base.validates_uniqueness_of :tag, :allow_nil => true, :allow_nil => true
		base.has_many :links, :class_name => base.taggable_klass.taggable_link_klass.name, :foreign_key => 'tag_id', :dependent => :destroy
	end

	module ClassMethods
# we'll only add/removed this many unique tags at a time to avoid database abuse. This is a reasonable default and can be raised or lowered by over-riding this function
		def taggable_maximum_number_of_tags_to_add_or_remove
			100
		end

		def sanitize_tags( tags )
			tags = [tags] unless tags.is_a?(Array)
			tags.uniq!
			tags.slice(0..self.taggable_maximum_number_of_tags_to_add_or_remove).collect{|x|x.strip} #limit to 100 tags at a time by default
		end

		def find_with_tags( tags )
			tags = sanitize_tags(tags)
			tk = self.taggable_klass
			lk = tk.taggable_link_klass
			conds = [tags.collect{'tag = ?'}.join(' OR ')]
			conds.concat( tags )
			self.taggable_klass.find( :all, :joins => "INNER JOIN #{lk.table_name} ON #{lk.table_name}.taggable_id = #{tk.table_name}.id INNER JOIN #{self.table_name} ON #{self.table_name}.id = #{lk.table_name}.tag_id", :conditions => conds )
		end
	end #ClassMethods
end #Base

module Link
	def self.included(base)
		base.extend(ClassMethods)
		base.belongs_to :tag, :class_name => base.taggable_klass.taggable_base_klass.name, :foreign_key => 'tag_id', :dependent => :destroy
		base.belongs_to :taggable, :class_name => base.taggable_klass.name, :foreign_key => 'taggable_id'
		base.validates_numericality_of :use_count
	end

	module ClassMethods
	end #ClassMethods
end #Link

module Taggable
	def self.include(base)
		base.extend(ClassMethods)
	end


	def taggable; TagList.new( self ); end


	module ClassMethods
	end #ClassMethods

	class TagList
		attr_reader :taggable
		def initialize( taggable_instance )
			@taggable = taggable_instance
		end

		def add( tags )
			tags = self.taggable.class.taggable_base_klass.sanitize_tags( tags )
			conds = [tags.collect{'tag = ?'}.join(' OR ')]
			conds.concat( tags )

			self.taggable.class.taggable_link_klass.transaction do
				existing_tag_links = self.taggable.class.taggable_link_klass.find(:all, :joins => "INNER JOIN #{self.taggable.class.taggable_base_klass.table_name} ON #{self.taggable.class.taggable_base_klass.table_name}.id = #{self.taggable.class.taggable_link_klass.table_name}.tag_id", :conditions => conds, :select => "#{self.taggable.class.taggable_link_klass.table_name}.*", :include => self.taggable.class.taggable_base_klass.name.underscore.to_s )

				# all existing links need their counts updated by 1
				existing_tag_links.each {|link| link.use_count += 1}
				# Throw out any tags we've already hit: reject tags detected in the existing tag links
				new_tags = tags.reject{|t| !existing_tag_links.detect{|l| l.tag.tag.eql?( t ) }.nil? }
				new_tags = new_tags.collect{|t| self.taggable.class.taggable_base_klass.new( :tag => t ) }
# OK: Save the existing links
				existing_tag_links.each {|t| t.save!}
# OK: Save 'em!
				# new tags might not save
				new_tags.each {|t| t.save}
				failed_new_tags = new_tags.each.select{|t| t.id.nil? }
				new_tags = new_tags.reject{|t| t.id.nil? }
				new_tag_links = new_tags.collect{|t| self.taggable.class.taggable_link_klass.new( :tag_id => t.id, :taggable_id => self.taggable.id ) }
# Save the new links!
				new_tag_links.each {|t|t.save!}
				{ :failed => failed_new_tags, :succeeded => ( new_tags | existing_tag_links.collect{|t| t.tag} ) }
			end
		end

		def remove_completely( tags )
			tags = self.taggable.class.taggable_base_klass.sanitize_tags( tags )
			conds = ['taggable_id = ? AND ',self.taggable.id]
			conds[0] += '(' + tags.collect{'? = tag'}.join(' OR ') + ')'
			conds.concat( tags )
			self.taggable.class.taggable_base_klass.transaction do
				links = self.taggable.class.taggable_link_klass.find( :all, :conditions => conds, :joins => "INNER JOIN #{self.taggable.class.taggable_base_klass.table_name} ON #{self.taggable.class.taggable_base_klass.table_name}.id = #{self.taggable.class.taggable_link_klass.table_name}.tag_id", :readonly => false )
				links.each {|l| l.destroy }
			end
		end

		def remove( tags, count = 1 )
			tags = self.taggable.class.taggable_base_klass.sanitize_tags( tags )
			conds = ['taggable_id = ? AND ',self.taggable.id]
			conds[0] += '(' + tags.collect{'? = tag'}.join(' OR ') + ')'
			conds.concat( tags )
			self.taggable.class.taggable_base_klass.transaction do
				# Find any links that will be affected
				links = self.taggable.class.taggable_link_klass.find( :all, :conditions => conds, :joins => "INNER JOIN #{self.taggable.class.taggable_base_klass.table_name} ON #{self.taggable.class.taggable_base_klass.table_name}.id = #{self.taggable.class.taggable_link_klass.table_name}.tag_id", :readonly => false )

				links.each do |link|
					# Prevent setting below zero
					unless link.use_count < count
						link.use_count -= count
					else
						link.use_count = 0
					end
				end

				# Delete any that are empty, update the rest
				links.reject{|l| l.use_count.eql?0 }.each {|l| l.save! }
				links.select{|l| l.use_count.eql?0 }.each {|l| l.destroy }
			end
		end

		def tag_cloud_data( topcount = nil )
			tag_links = self.taggable.class.taggable_link_klass.find(:all, :conditions => ['taggable_id = ?', self.taggable.id], :include => :tag, :limit => topcount, :order => 'use_count DESC' )
			ret = {}
			tag_links.each {|t| ret[t.tag.tag] = t.use_count }
			ret
		end
	end
end #Taggable

module BaseMigration
	def self.included(base)
		base.extend(ClassMethods)
	end

	module ClassMethods
		def create_tag_table( table_name, &block )
			create_table(table_name) do |t|
				t.column :tag, :string, :limit => 64, :null => false
				yield(t) if block_given?
			end
			add_index table_name, :tag, :unique => true
		end
	end #ClassMethods
end #BaseMigration

module LinkMigration
	def self.included(base)
		base.extend(ClassMethods)
	end

	module ClassMethods

		def create_link_tags_with_taggable_table( table_name, &block )
			create_table( table_name ) do |t|
				t.column :tag_id, :integer, :null => false
				t.column :taggable_id, :integer, :null => false
				t.column :use_count, :integer, :default => 1, :null => false
				t.timestamps
				yield(t) if block_given?
			end
			add_index table_name, [:tag_id,:taggable_id], :unique => true
		end

	end #ClassMethods
end #LinkMIgration

end #Taggable
end #ActsAs
end #CW
