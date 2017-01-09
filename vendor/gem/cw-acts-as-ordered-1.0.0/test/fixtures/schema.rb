ActiveRecord::Schema.define do
	create_table 'users' do |t|
		t.column 'name', :string
	end
	create_table 'candies' do |t|
		t.column 'name', :string
	end
	create_table 'watches' do |t|
		t.column 'name', :string
	end
end
