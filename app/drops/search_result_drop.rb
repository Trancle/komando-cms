class SearchResultDrop < BaseDrop
	include ShowsHelper

	def initialize( result, controller )
		@result = result
		@controller = controller
	end

	def current_result
		case result_type
			when 'Episode'
				@result.result.current_version_or_latest
      when 'Show'
        @result.result.scheduled_version_current_or_last_version
      when 'ShowOfTag'
        @result.result.scheduled_version_current_or_last_version
			else
				nil
		end
	end
	protected :current_result

	def url_to_content
		case result_type
			when 'Episode'
				url_for( url_to_episode( @result.result.show.scheduled_version_current_or_last_version, current_result ) )
      when 'Show'
        url_for( url_to_show( current_result ) )
      when 'ShowOfTag'
        url_for( url_to_show( current_result ) )
			else
				nil
		end
  end

  def image_hash
    case result_type
      when 'Episode'
        current_result.image_still_hash
      when 'Show'
        current_result.image_still_hash
      when 'ShowOfTag'
        current_result.image_still_hash
      else
        nil
    end
  end

  def image_ext
    case result_type
      when 'Episode'
        current_result.episode_still_image.file_extension
      when 'Show'
        current_result.show_still_image.file_extension
      when 'ShowOfTag'
        current_result.show_still_image.file_extension
      else
        nil
    end
  end

	def title
		current_result.title
  end

  def description
    case result_type
      when 'Episode'
        current_result.description
      when 'Show'
        current_result.description
      when 'ShowOfTag'
        current_result.description
      else
        nil
    end
  end

	def result_type
		@result.result.class.name
	end

	def confidence
		(@result.rank*100.0).to_i.to_s
	end

end
