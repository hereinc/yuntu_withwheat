# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#

# job_type :r,    "cd :path && :environment_variable=:environment bundle exec rake :task --silent :output"
# ~/.rvm/bin/rvm ruby-2.2.2@yuntu_dashboard do ruby
every 1.hours do
  runner 'Dir.pwd'
  command 'ls'
end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
