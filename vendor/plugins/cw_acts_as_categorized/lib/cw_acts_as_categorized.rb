# CwActsAsCategorized
module CW
module ActsAs
module Categorized

	# Base class for category model
	module Base
		def self.included(base)
			base.extend(ClassMethods)
			base.validates_presence_of :name
			base.validates_length_of :name, :in => 1..256, :allow_nil => true
			base.validates_uniqueness_of :name, :allow_nil => true, :allow_nil => true
		end

		def find_all_categorizeables( orderby = nil )
			opts = options_to_find_categorizeables
			opts[:order] = orderby unless orderby.nil?
			self.class.categorizeable_klass.find(:all, opts )
		end

		def options_to_find_categorizeables()
			self.class.options_to_find_categorizeables( self.id )
		end

		module ClassMethods


			def options_to_find_categorizeables( category_ids )
				category_ids = [category_ids] unless category_ids.is_a?(Array)
				ck = categorizeable_klass
				clk = ck.category_link_klass

				select = "#{ck.table_name}.*"
				join = "INNER JOIN #{clk.table_name} ON #{clk.table_name}.categorizeable_id = #{ck.table_name}.id"
				conds = ['(' + category_ids.collect{"#{clk.table_name}.category_id = ?"}.join(' OR ') + ')']
				conds.concat( category_ids )
				

				{ :select => select, :joins => join, :conditions => conds }
			end
		end #ClassMethods
	end #Base

	# included in models that want to link up to category table
	module Categorizeable
		def self.included(base)
			base.extend(ClassMethods)
			base.has_many :link_categorizeable_with_categories, :class_name => base.category_link_klass.name, :dependent => :destroy, :foreign_key => 'categorizeable_id'
			base.has_many :categories, :through => :link_categorizeable_with_categories
		end


		def category_add( category_instances )
			category_instances = [category_instances] unless category_instances.is_a?(Array)
			links = []
			category_instances.each do |inst|
				links << self.class.category_link_klass.new( :category_id => inst.id, :categorizeable_id => self.id )
			end
			self.class.transaction do
				links.each {|link| link.save!}
			end
			links
		end
		def category_remove( category_instances )
			category_instances = [category_instances] unless category_instances.is_a?(Array)
			self.class.transaction do
				conds = ['categorizeable_id = ?',self.id]
				instance_ids = category_instances.collect{|inst|inst.id}
				conds[0] += ' AND (' + instance_ids.collect{ '(category_id = ?)' }.join(' OR ') + ')'
				conds.concat(instance_ids)
				self.class.category_link_klass.destroy_all( conds )

			end
		end

		module ClassMethods
		end #ClassMethods
	end #Categorizable


	# Model to link the categorizabled class to the category base class
	module Link
		def self.included(base)
			base.extend(ClassMethods)
			base.belongs_to :category, :class_name => base.category_base_klass.name
			base.belongs_to :categorizeable, :class_name => base.category_categorizeable_klass.name, :foreign_key => 'categorizeable_id'
		end
		module ClassMethods
		end #ClassMethods
	end #Link


	# Creates a category table
	module BaseMigration
		def self.included(base)
			base.extend(ClassMethods)
		end
		module ClassMethods
			def create_categories( table_name, &block )
				create_table( table_name ) do |t|
					t.column :name, :string, :limit => 256, :null => false
					yield(t) if block_given?
				end
				add_index table_name, :name, :unique => true
			end
		end #ClassMethods
	end #BaseMigration


	module LinkMigration
		def self.included(base)
			base.extend(ClassMethods)
		end
		module ClassMethods
			def	create_link_categorizeable_with_categories( table_name, &block )
				create_table( table_name ) do |t|
					t.column :categorizeable_id, :integer, :null => false
					t.column :category_id, :integer, :null => false
					t.column :created_at, :timestamp, :null => false
					yield(t) if block_given?
				end
				add_index table_name, [:categorizeable_id, :category_id], :unique => true
			end
		end #ClassMethods
	end #LinkMigration


end #Categorized
end # ActsAs
end #CW
