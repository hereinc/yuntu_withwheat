require File.expand_path('../setup', __FILE__)
require File.expand_path('../ym_metric', __FILE__)
require File.expand_path('../cohort', __FILE__)
require File.expand_path('../average_order_size', __FILE__)

NewUsers.compute(Time.now - 15.days, Time.zone.now)
YMMetric.sync
NewUsers.sync
Cohort.sync
AverageOrderSize.sync