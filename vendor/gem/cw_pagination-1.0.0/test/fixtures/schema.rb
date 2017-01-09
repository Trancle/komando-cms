ActiveRecord::Schema.define do
	create_table 'users' do |t|
		t.column 'first', :string
		t.column 'middle', :string
		t.column 'last', :string
		t.column 'age', :integer
		t.column 'height', :integer
	end
end
