# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, "/var/www/yuntu_withwheat/shared/log/cron_log.log"

job_type :ruby,  "cd :path && ~/.rvm/bin/rvm ruby-2.2.2@yuntu_withwheat do bundle exec ruby :task :output"

every 1.hours do
  ruby 'sync.rb'
end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
