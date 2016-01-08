require File.expand_path('../setup', __FILE__)
require File.expand_path('../ym_metric', __FILE__)
require File.expand_path('../cohort', __FILE__)
require File.expand_path('../average_order_size', __FILE__)

YMMetric.sync
NewUsers.sync
Cohort.sync
AverageOrderSize.sync