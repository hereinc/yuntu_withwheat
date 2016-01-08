require File.expand_path('../setup', __FILE__)

module AverageOrderSize
  class << self
    def sync
      start_time = (Time.now-6.days).beginning_of_day.to_datetime
      end_time = Time.now.end_of_day.to_datetime
      result = OrderItem.paid.where('pay_time >= ? AND pay_time <= ?', start_time, end_time).group('DATE(pay_time)').select('sum(pay_price) as daily_gmv, count(distinct(order_id)) as daily_orders_count')

      daily_gmv = result.sum(:pay_price)
      daily_orders_count = result.distinct.count(:order_id)

      history = []
      (start_time..end_time).step(1).each do |time|
        date = time.to_date
        daily_count = daily_orders_count[date]
        if daily_count.nil? || daily_count == 0
          history << 0
        else
          history << daily_gmv[date] / daily_count.to_f
        end
      end

      data = {
        "item": [
          {
            "value": history[-1]
          }, history
        ]
      }

      Geckoboard.push "172028-0e08f4be-70cb-482b-918c-6b7074082d3f", data
    end
  end
end

