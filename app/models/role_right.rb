class RoleRight < ActiveRecord::Base
	belongs_to :user_role

	validates_presence_of :user_role_id
	validates_numericality_of :user_role_id, :allow_nil => true, :only_integer => true

	validates_presence_of :controller_name
	validates_length_of :controller_name, :maximum => 1024, :allow_nil => false, :allow_blank => false
	validates_presence_of :action_name
	validates_length_of :action_name, :maximum => 1024, :allow_nil => false, :allow_blank => false

	validates_length_of :description, :maximum => 1024, :allow_nil => true, :allow_blank => true
end
