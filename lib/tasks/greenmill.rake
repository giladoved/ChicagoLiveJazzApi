desc "get greenmill info"
task :greenmill => :environment do
  GreenMillController.new.daily_update
end
