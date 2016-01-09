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