class AuthPageIsLayout < ActiveRecord::Migration

	ActionView::Helpers
  def self.up

		# creates a new page layout for the /auth path, required in the version being migrated to

		default_layout = <<EOD
<h1 id="login-form">Login</h1>
{% if form.error_message? %}<p class="Error Message">{{ form.error_message }}</p>{% endif %}
<div id="login-form">
	{{ form.open }}
	<p><label for="{{ form.username_field_id }}">Username</label>{{ form.username_text_field }}</p>
	<p><label for="{{ form.password_field_id }}">Password</label>{{ form.password_password_field }}</p>
	<p><label for="{{ form.remember_me_field_id }}">Remember me?</label>{{ form.remember_me_check_box_field }}</p>
	<p><input type="submit" value="login" /></p>
	{{ form.close }}
</div>
EOD


		transaction do
			unless PageLayout.exists?( { :programmatic_name => 'auth-index-page' } )
				pl = PageLayout.new(  )
				pl.name = 'Login page (/auth)'
				pl.programmatic_name = 'auth-index-page'
				pl.description = <<EOD
<p>This is the page users see when they are asked to log into the site.</p>
<dl>
	<dt>form</dt>
	<dd>Liquid Drop with the following methods: <dl>
		<dt>error_message</dt>
		<dd>The error message that is to appear if the login failed for some reason (only appears if the user tried to log in and it failed)</dd>
		<dt>error_message?</dt>
		<dd>True only if an error message was supplied</dd>
		<dt>open</dt>
		<dd>Start the form-tag. Creates a form tag with action and method attributes pre-defined. Alse creates a hidden (by style) div contaning redirection information required by the login process</dd>
		<dt>close</dt>
		<dd>Ends the form-tag that is opened by "open." Provided for uniformity and convenience as well as for future-proofing versions with additional functionality.</dd>
		<dt>username_field_id</dt>
		<dd>The id attribute of the input tag associated with the username. This is provided to you for scripting and labels.</dd>
		<dt>password_field_id</dt>
		<dd>The id attribute of the input tag associated with the password. This is provided to you for scripting and labels.</dd>
		<dt>remember_me_field_id</dt>
		<dd>The id attribute of the input tag associated with the remember me checkbox. This is provided to you for scripting and labels.</dd>
		<dt>username_text_field</dt>
		<dd>The input field where the user types his or her username</dd>
		<dt>password_text_field</dt>
		<dd>The input field where the user types his or her password</dd>
		<dt>remember_me_check_box_field</dt>
		<dd>A simple checkbox to adjust how long the site will remember the user's login. This setting is set by you in the admin settings.</dd>
	</dl></dd>
</dl>
<p>Example</p>
<pre>
#{ERB::Util::h(default_layout)}
</pre>
EOD
				pl.save
				plv = pl.make_first_version()
				plv.layout = default_layout
				plv.version_comment = "Initial, generated version"
				plv.version_stub_id = pl.id
				plv.editor_id = 0
				raise plv.errors.full_messages.join(', ') unless plv.save

				dr = PageLayoutScheduleDateRange.new
				dr.exclusivity_id = pl.id
				dr.save
				pl.scheduled_version_schedule_version_with_range( plv, dr )
			end
		end
  end

  def self.down
		PageLayout.find_by_programmatic_name( 'auth-index-page' ).destroy
  end
end
