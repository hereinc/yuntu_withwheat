require 'airbrake'
Airbrake.configure do |config|
  config.api_key = '28d16925fef3254dabfc128783bde85b'
  config.host    = 'errbit.kechenggezi.com'
  config.port    = 80
  config.secure  = config.port == 443
end

begin
  require File.expand_path('../setup', __FILE__)
  require File.expand_path('../importer', __FILE__)
  require File.expand_path('../cohort', __FILE__)
  require File.expand_path('../ym_metric', __FILE__)
  require File.expand_path('../average_order_size', __FILE__)

  now = Time.zone.now
  Importer.new.import_all (now - 7.days).strftime('%Y-%m-%d'), now.strftime('%Y-%m-%d')
  NewUsers.compute(now - 7.days, now)
  YMMetric.sync
  NewUsers.sync
  Cohort.sync
  AverageOrderSize.sync
rescue => e
  Airbrake.notify_or_ignore(
   e,
   parameters: {now: now},
   cgi_data: ENV.to_hash
  )
end

