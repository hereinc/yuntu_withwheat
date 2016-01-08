require File.expand_path('../setup', __FILE__)

def gobal_gmv time = Time.now
  end_of_year = time.end_of_year

  result = OrderItem.where(order_status: ['PAID', 'RECEIVED']).where('pay_time >= ? AND pay_time <= ?', time.beginning_of_year, time.end_of_year).sum('pay_price')

  data = {
    "item": [
      {
        "text": "#{time.year}年营业额",
        "value": result,
        "prefix": "￥"
      }
    ]
  }

  Geckoboard.push "172028-eaaa6a61-df4b-49eb-adf6-814900c91037", data
end

def gmv_per_month
  month_gmv = OrderItem.group('YEAR(pay_time), MONTH(pay_time)').where(order_status: ['PAID', 'RECEIVED']).select('pay_time, sum(pay_price) as day_gmv').map do |o|
    [o.pay_time.strftime('%Y-%m'), o.day_gmv.to_f]
  end

  month_gmv = Hash[month_gmv]

  now = Time.now

  labels = 6.times.map{ |i| (now - i.months).strftime('%Y-%m') }.reverse
  series = labels.map{|label| month_gmv[label] || 0 }

  data = {
    "x_axis": {
      "labels": labels
    },
    "y_axis": {
      "format": "currency",
      "unit": "CNY"
    },
    "series": [
      {
        "data": series
      }
    ]
  }

  Geckoboard.push "172028-d5963c84-cf3e-492d-a374-a7924e46f1cd", data
end

def gmv_per_day
  day_gmv = OrderItem.group('DATE(pay_time)').where(order_status: ['PAID', 'RECEIVED']).select('pay_time, sum(pay_price) as day_gmv').map do |o|
    [o.pay_time.strftime('%m-%d'), o.day_gmv.to_f]
  end

  day_gmv = Hash[day_gmv]

  now = Time.now

  labels = 7.times.map{ |i| (now - i.day).strftime('%m-%d') }.reverse
  series = labels.map{|label| day_gmv[label] || 0 }

  data = {
    "x_axis": {
      "labels": labels
    },
    "y_axis": {
      "format": "currency",
      "unit": "CNY"
    },
    "series": [
      {
        "data": series
      }
    ]
  }

  Geckoboard.push "172028-b27d7ffc-70bb-476e-81ba-991f4a92a3cf", data
end

def purchase_frequency
  user_purchase_times = OrderItem.group('order_id, user_id').where(order_status: ['PAID', 'RECEIVED']).size

  pf = Hash.new(0)

  user_purchase_times.each do |k, v|
    pf[v] += 1
  end

  limits = [1, 3, 5, 7, 9]

  vary_large_number = 999999999

  range_purchase_times = limits.each_with_index.map do |i, index|
    start_limit = i
    end_limit = limits[index + 1] || vary_large_number
    range = (start_limit...end_limit)
    sum = pf.select{|k, v| range.include?(k) }.values.sum
    ["#{start_limit}#{end_limit == vary_large_number ? '+' : "-#{end_limit - 1}" }", sum]
  end

  labels = range_purchase_times.map{ |x| x[0] }
  series = range_purchase_times.map{ |x| x[1] }

  data = {
    "x_axis": {
      "labels": labels
    },
    "y_axis": {
       "format": "decimal"
    },
    "series": [
      {
        "data": series
      }
    ]
  }

  Geckoboard.push "172028-c3b563ab-ec5c-4638-8da7-ec24071a2721", data
end

def total_repurchase_rate time_limit = Time.now
  user_purchase_times = OrderItem.group('order_id, user_id').where(order_status: ['PAID', 'RECEIVED']).where('pay_time < ?', time_limit).size

  multi_purchases_user_count = 0
  single_purchase_user_count = 0

  user_purchase_times.each do |user_id, purchase_count|
    if purchase_count > 1
      multi_purchases_user_count += 1
    else
      single_purchase_user_count += 1
    end
  end

  all_count = user_purchase_times.count.to_f

  result = if all_count == 0
    0
  else
    multi_purchases_user_count / all_count * 100
  end
end

def repurchase_rate
  now = Time.now

  results = 6.times.map do |i|
    total_repurchase_rate now - i * 1.days
  end.reverse

  data = {
    "absolute": true,
    "item": [
      {
        "text": "",
        "value": results[-1],
        "prefix": "%"
      },
      results
    ]
  }

  Geckoboard.push "105750-6172e6d0-8c0b-0133-60fd-22000b5a09a4", data
end

gobal_gmv
gmv_per_month
gmv_per_day
purchase_frequency
repurchase_rate