require 'test_helper'

class UserAgentTest < ActiveSupport::TestCase
  fixtures :all

	UAS = {
		'safari' => {
			'mac' => {
				'10.6.7' => {
					'5.0.4' => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_7; en-us) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.4 Safari/533.20.27"
					}
				},
			'iphone' => {
				'4.3.1' => {
					'5.0.2' => "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_1 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8G4 Safari/6533.18.5"
				}
			}
		},
		'firefox' => {
			'mac' => {
				'10.6.7' => {
					'4.0' => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0) Gecko/20100101 Firefox/4.0"
				}
			}
		},
		'chrome' => {
			'mac' => {
				'10.6.7' => {
					'11' => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_7) AppleWebKit/534.24 (KHTML, like Gecko) Chrome/11.0.696.34 Safari/534.24"
				}
			},
			'windows' => {
				'vista' => {
					'11' => "Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US) AppleWebKit/534.16 (KHTML, like Gecko) Chrome/10.0.648.133 Safari/534.16"
				}
			}
		},
		'opera' => {
			'windows' => {
				'vista' => {
					'11' => 'Opera/9.80 (Windows NT 6.0; U; en) Presto/2.7.62 Version/11.00'
				}
			}
		},
		'msie' => {
			'windows' => {
				'vista' => {
					'9.0' => 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)',
					'8.0' => 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/5.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E; InfoPath.3; Creative AutoUpdate v1.40.02)',
					'7.0' => 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; WOW64; Trident/5.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E; InfoPath.3; Creative AutoUpdate v1.40.02)'
				},
				'xp' => {
					'6.0' => 'Mozilla/4.0 (compatible; MSIE 6.0; Windows 98; Rogers Hi·Speed Internet; (R1 1.3))'
				}
			}
		}
	}.freeze

	def make_ua( args )
		ua = UAS
		args.each do |a|
			ua = ua[a]
		end
		UserAgent.new( ua )
	end

  # Replace this with your real tests.
  test "safari iphone ios" do
		ua = make_ua( %w(safari iphone 4.3.1 5.0.2) )
    assert ua.iphone?
    assert ua.ios?
    assert !ua.ipod?
		assert ua.safari?
		assert_equal :safari, ua.browser
		assert_equal ComponentizedProductVersion.new( '5.0.2' ), ua.browser_version

# test against not safari
		ua = make_ua( %w(safari mac 10.6.7 5.0.4) )
    assert !ua.iphone?
    assert !ua.ios?
    assert !ua.ipod?
		assert ua.safari?

		assert_equal :safari, ua.browser
		assert_equal ComponentizedProductVersion.new( '5.0.4' ), ua.browser_version
  end

	test "ios version" do
		ua = make_ua( %w(safari iphone 4.3.1 5.0.2) )
		assert ua.safari?
		bv = ua.version_safari
		assert_equal ComponentizedProductVersion.new( '5.0.2' ), bv
		assert_equal ComponentizedProductVersion.new( '5.0.2' ), ua.browser_version
		assert_equal :safari, ua.browser
	end

	test "ie" do
		ua = make_ua %w(msie windows vista 9.0)
		assert ua.msie?
		assert ua.ie?
		assert_equal ComponentizedProductVersion.new( '9.0' ), ua.version_ie
		assert_equal ComponentizedProductVersion.new( '9.0' ), ua.browser_version
		assert_equal :msie, ua.browser

		ua = make_ua %w(msie windows vista 8.0)
		assert ua.msie?
		assert ua.ie?
		assert_equal ComponentizedProductVersion.new( '8.0' ), ua.version_ie
		assert_equal ComponentizedProductVersion.new( '8.0' ), ua.browser_version
		assert_equal :msie, ua.browser

		ua = make_ua %w(msie windows vista 7.0)
		assert ua.msie?
		assert ua.ie?
		assert_equal ComponentizedProductVersion.new( '7.0' ), ua.version_ie
		assert_equal ComponentizedProductVersion.new( '7.0' ), ua.browser_version
		assert_equal :msie, ua.browser

		ua = make_ua %w(msie windows xp 6.0)
		assert ua.msie?
		assert ua.ie?
		assert_equal ComponentizedProductVersion.new( '6.0' ), ua.version_ie
		assert_equal ComponentizedProductVersion.new( '6.0' ), ua.browser_version

		assert_equal :msie, ua.browser
	end



end
