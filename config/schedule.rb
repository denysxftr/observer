# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

job_type :thor, 'cd :path && bundle exec thor :task'


every 10.minutes do
  thor 'processing:states_check'
  thor 'processing:clear_old'
end

every 5.minutes do
  thor 'processing:http_check'
  thor 'processing:create_log_states'
end

every 6.hours do
  thor 'processing:trends_check'
end
