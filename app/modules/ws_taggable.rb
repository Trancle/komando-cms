# Custom module to be included in models to provide for easier tagging

module WS
  module Taggable



    def self.included(base)
      base.extend(ClassMethods)
    end


    # list the tags for this object
    def tags_as_string
      self.tags.map{|t| t.tag}.join(',')
    end


    def assign_tags( tas )
      # Make constant klasses for later use
      #tagk = (self.class.class_name_override_for_tagging + 'Tag').constantize
      #taggingk = (self.class.class_name_override_for_tagging + 'Tagging').constantize

      # Format the tags as strings, remove any empty strings
      tags = self.class.tag_string_to_array( tas ).collect{|t| t.strip}.reject{|t| t.empty?}

      # find all existing taggings
      existing_taggings = self.taggings.find(:all)
      remove_taggings( existing_taggings.reject{|tg| tags.include?(tg.tag.tag) } )
      add_tags( tags )
    end

    # expects array of strings
    def add_tags(tags)
      tagk = (self.class.class_name_override_for_tagging + 'Tag').constantize
      taggingk = (self.class.class_name_override_for_tagging + 'Tagging').constantize
      # find all existing taggings
      existing_taggings = self.taggings.find(:all)
      tags = tags.collect{|t| t.strip}
      tags.reject!{|t| t.empty?}
      taggings_to_create = tags.reject{|tag| existing_taggings.map{|tg| tg.tag.tag }.include?(tag) }
      taggings_to_create.each do |tag|
        t = tagk.first(:conditions => {:tag => tag})
        if t.nil?
          t = tagk.new(:tag => tag)
          t.save
        end
        taggingk.create( self.class.class_name_override_for_tagging.underscore + '_id' => self.id, :tag_id => t.id )
      end
      true
    end


    # expects array of Tagging instances
    def remove_tags( tags )
      tagk = (self.class.class_name_override_for_tagging + 'Tag').constantize
      taggingk = (self.class.class_name_override_for_tagging + 'Tagging').constantize
      # Remove taggings that are no longer referenced
      tags.each do |t|
        old_tag_id = t.tag.id
        t.destroy
        # if nothing else references that tag, then destroy the tag
        unless taggingk.exists?( { :tag_id => old_tag_id } )
          tagk.destroy( old_tag_id )
        end
      end
      true
    end







    module ClassMethods
      def suggest_tags( tas, limit = 5 )
        tagk = (self.name + 'Tag').constantize
        last_tag = (tas.split(',').last || '').strip
        # find a tag that matches the start of what we have so far
        tagk.all( :limit => limit, :conditions => ['tag like ?', '%' + last_tag + '%']).map{|t| t.tag}
      end

      def tag_string_to_array( s )
        s.split(',').map do |t|
          t.strip.downcase
        end
      end

      def class_name_override_for_tagging
        self.name
      end
    end
  end
end