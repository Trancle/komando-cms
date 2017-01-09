class SitemapUrl
	include ShowsHelper
	attr_accessor :lastmod, :changefreq, :priority, :result_type, :result_id, :result


	def initialize( attrs = {} )
		attrs.each do |k,v|
			send( k.to_s + '=', v )
		end
	end

	def self.find
		res = ActiveRecord::Base.connection.execute( find_sql( :show => 10, :episode => 20 ) )
		res = res.collect do |r|
			SitemapUrl.new( :result_type => r[0], :result_id => r[1].to_i, :lastmod => r[2].to_time, :changefreq => r[3], :priority => r[4] )
		end
		lookup_versions( res )
	end


	def self.find_sql( limit )
		if limit.is_a?(Numeric)
			l = limit
			limit = {}
			limit[:show] = l
			limit[:episode] = l
		end
		showopts = Show.find_available_show_options()
		episodeopts = Episode.find_available_episode_options()
		episodeorder = Episode.order_episodes_reverse_season_and_episode_number
ret = <<EOD
( SELECT 'Show' AS result_type, shows.id AS result_id, show_versions.updated_at AS lastmod, 'monthly' AS changefreq, 0.9 AS priority
FROM shows
#{showopts[:joins]} INNER JOIN show_versions ON show_versions.version_stub_id = shows.id AND show_versions.id = show_version_schedules.version_id AND show_version_schedules.cw_mu_ex_date_range_id = show_version_schedule_dates.id
WHERE #{showopts[:conditions][0]}
ORDER BY show_version_schedule_dates.start_at DESC
LIMIT #{limit[:show]} )
UNION
( SELECT 'Episode' AS result_type, episodes.id AS result_id, episode_versions.updated_at AS lastmod, 'weekly' AS changefreq, 0.1 AS priority
FROM episodes
#{episodeopts[:joins]} INNER JOIN episode_versions ON episode_versions.id = episodes.current_version_id
WHERE #{episodeopts[:conditions][0]}
ORDER BY #{episodeorder}
LIMIT #{limit[:episode]} )
EOD
		ret = [ret]
		ret.concat showopts[:conditions][1..-1]
		ret.concat episodeopts[:conditions][1..-1]
		ActiveRecord::Base.sanitize_sql_array( ret )
	end

	def self.lookup_versions( results )
		mid = {}
		# organize the results by class type (name). Create a list of id's sorted by type
		results.each do |r|
			mid[r.result_type] = [] unless mid.key?( r.result_type )
			mid[r.result_type] << r.result_id
		end

		res = []
		# look up the ID's to get the object stored in the database of each type.
		mid.each_key do |t|
			res.concat( t.constantize.all( :conditions => { :id => mid[t] } ) )
    end

    res.compact! # remove nil entries

		# For each object found by ID, associate the class with it
		res.each do |r|
			re = results.find {|f| f.result_id.eql?(r.id) and f.result_type.eql?(r.class.name) }
			re.result = r if re
		end

		results
	end

	def url_opts
    case self.result.class.name
      when 'Episode'
        url_to_episode( self.result.show.scheduled_version_current_or_last_version, self.result.current_version )
      when 'Show'
        url_to_show( self.result.scheduled_version_current_or_last_version )
    end
	end

end
