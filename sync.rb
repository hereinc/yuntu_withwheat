require File.expand_path('../setup', __FILE__)
require File.expand_path('../ym_metric', __FILE__)
require File.expand_path('../cohort', __FILE__)
require File.expand_path('../average_order_size', __FILE__)

now = Time.zone.now
Importer.new.import_all (now - 7.days).strftiem('%Y-%m-%d'), now.strftiem('%Y-%m-%d')
NewUsers.compute(now - 7.days, now)
YMMetric.sync
NewUsers.sync
Cohort.sync
AverageOrderSize.sync