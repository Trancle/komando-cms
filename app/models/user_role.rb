class UserRole < ActiveRecord::Base
	has_many :link_user_with_user_roles
	has_many :users, :through => :link_user_with_user_roles
	has_many :role_rights

	validates_presence_of :name
	validates_length_of :name, :allow_nil => true, :in => 1..256
	validates_uniqueness_of :name, :allow_nil => true
	validates_length_of :description, :allow_blank => true, :maximum => 1024

  # NOTE: THis class is currently unused. Implemented, but not enforced
end
