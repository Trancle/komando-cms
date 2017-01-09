class SearchResult
	attr_reader :result_type, :snippet, :rank, :result_id
	attr_accessor :result

	def initialize( attributes )
		@result_type = attributes[:result_type]
		@snippet = attributes[:snippet]
		@rank = attributes[:rank].to_f
		@result_id = attributes[:result_id].to_i
		@result = nil
	end

	# Prepares a list of search results based on the terms
	def self.find( *args )
		args = parse_find_count_args( *args ).first

		sql = find_sql( args[:terms] )
		sql += " LIMIT #{args[:limit]}" if args[:limit]
		sql += " OFFSET #{args[:offset]}" if args[:offset]

		ret = ActiveRecord::Base.connection.execute( sql ).collect do |t|
			SearchResult.new( :result_type => t[0], :snippet => t[1], :result_id => t[2], :rank => t[3] )
		end
		lookup_result_and_attach_to_models( ret )
	end

	def self.count( *args )
		ActiveRecord::Base.connection.execute( count_sql( args.first[:terms] ) ).first.first.to_i
	end

	def self.find_sql( terms )
		terms = process_terms(terms)

		show_opts = Show.find_available_show_options()
		episode_opts = Episode.find_available_episode_options()

sql = <<endofdoc
SELECT 'Show' AS result_type, '' AS snippet, shows.id AS id, ts_rank( show_versions.ts_index, to_tsquery('english',?) ) AS rank
FROM shows
#{show_opts[:joins]} INNER JOIN show_versions ON show_versions.version_stub_id = shows.id AND show_version_schedules.version_id = show_versions.id
WHERE to_tsquery('english',?) @@ show_versions.ts_index AND ( #{show_opts[:conditions][0]} )
UNION
SELECT 'Episode' AS result_type, '' AS snippet, episodes.id AS id, ts_rank( episode_versions.ts_index, to_tsquery('english',?) ) AS rank
FROM episodes
#{episode_opts[:joins]} INNER JOIN episode_versions ON episodes.current_version_id = episode_versions.id
WHERE to_tsquery('english',?) @@ episode_versions.ts_index AND ( #{episode_opts[:conditions][0]} )
ORDER BY rank DESC
endofdoc

		# ensure no SQL injection is possible
		ActiveRecord::Base.sanitize_sql_array( [sql,terms,terms].concat( show_opts[:conditions][1..-1] ).concat([terms,terms]).concat( episode_opts[:conditions][1..-1] ) )
	end

	def self.count_sql( terms )
		'SELECT COUNT(*) as count FROM ( ' + find_sql( terms ).gsub( /^ORDER BY.*$/, '' ).gsub( /, ts_rank\( .* \) AS rank/, '' ) + ') as u'
	end


# string of terms
	def self.process_terms( terms )
		# erase any non-number or letter
		terms = terms.dup
		terms.gsub!(/[^0-9a-zA-Z]/,' ')
		terms.squeeze!(' ')
		terms.gsub!(/\bor\b/i,'|')
		terms.gsub!(/\band\b/i,'&')
		words = terms.split(' ')
		ret = ''
		last = nil
		words.each do |word|
			# skip words that have been deleted due to my strict parsing rules
			unless word.empty?
				if last
					if (!word.eql?'&' and !word.eql?'|') and !last.eql?('&') and !last.eql?('|') and !last.eql?'(' and ( !last.eql?')' and !word.eql?')' )
						ret += ' & '
					end
				end
			end
			ret += ' ' + word
			last = word
		end
		ret
	end


	def self.parse_find_count_args( *args )
		# first arg will be :all, toss it
		args.shift
		args
	end

	def self.lookup_result_and_attach_to_models( results )

		mid = {}
		results.each do |r|
			mid[r.result_type] = [] unless mid.key?( r.result_type )
			mid[r.result_type] << r.result_id
		end

		res = []
		mid.each_key do |t|
			res.concat( t.constantize.find( :all, :conditions => { :id => mid[t] } ) )
		end

		res.each do |r|
			re = results.find {|f| f.result_id.eql?(r.id) and (f.result_type.eql?(r.class.name) or ( f.result_type.eql?('Show') and r.class.name.eql?('ShowOfTag') )) }
			re.result = r
		end

		results
	end

		def result=( r )
			@result = r
		end
end
