class PageLayoutVersion < ActiveRecord::Base
	include CW::ActsAs::Versioned::VersionedModel
	def self.scheduled_version_klass; "PageLayoutSchedule".constantize; end
	include CW::ScheduledVersion::Version

	validates_presence_of :editor_id
	validates_length_of :version_comment, :in => 3..4000

	belongs_to :page_layout, :foreign_key => 'version_stub_id'
end
