namespace :app do
desc "Sets up blocking for the dirty words in the user input blacklists"
task :pre_load_user_input_blacklist_dirty_words => :environment do

UserInputBlacklistExact.add_default_deadly_words
UserInputBlacklistRegularExpression.add_default_prevent_comment_links

end#task :pre_load_user_input_blacklist_dirty_words
end#namespace :app
