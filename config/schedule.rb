every ENV['JOB_INTERVAL'] do
  command "cd /#{ENV['COMPOSE_PROJECT_NAME']} && bundle exec cucumber"
end
