require File.expand_path('../setup', __FILE__)

module NewUsers
  NO_DATA_ARRAY = ['NIL']
  class << self
    def new_purchases_key(time)
      "new-purchases-" + time.strftime('%Y-%m-%d')
    end

    def active_purchase_key(time)
      "active-purchases-" + time.strftime('%Y-%m-%d')
    end

    # clean cache
    def clear
       $redis.del('all-users')
       $redis.keys('new-purchases-*').each { |k| $redis.del k }
       $redis.keys('active-purchases-*').each { |k| $redis.del k }
    end

    # fill cache
    def compute start_time, end_time
      start_time = start_time.beginning_of_day.to_datetime
      end_time = end_time.end_of_day.to_datetime

      (start_time..end_time).step(1).map do |time|
        on_date(time)
      end
    end

    def on_date(time)
      puts "Compute on_date #{time}"

      key = new_purchases_key(time)
      new_users = $redis.smembers(key)

      # cache empty
      if new_users == NO_DATA_ARRAY
        return []
      end

      # get cache
      if !new_users.empty?
        return new_users
      end

      # no cache
      sql = OrderItem.where(order_status: ['PAID', 'RECEIVED']).where('pay_time >= ? AND pay_time <= ?', time.beginning_of_day, time.end_of_day)
      # puts time.strftime('%Y-%m-%d')
      # puts sql.to_sql
      date_orders_users = sql.pluck('distinct(user_id)').map(&:to_s)
      # require 'pry'
      # binding.pry

      all_users = $redis.smembers('all-users')
      new_users = date_orders_users - all_users

      if time.to_date < Time.now.to_date
        $redis.sadd(active_purchase_key(time), date_orders_users) if !date_orders_users.empty?

        if !new_users.empty?
          $redis.sadd('all-users', new_users)
          $redis.sadd(key, new_users)
        else
          $redis.sadd(key, NO_DATA_ARRAY)
        end
      end

      new_users
    end

    def new_users_count(start_time, end_time = Time.now, frequency = 'day')
      result = []

      case frequency
      when 'day'
        result = compute(start_time, end_time).map(&:count)
      when 'month'
        start_time = start_time.beginning_of_month.to_datetime
        end_time = end_time.end_of_month.to_datetime

        month_count = 0
        (start_time..end_time).step(1).each do |time|
          month_count += on_date(time).count
          if time.to_date == time.end_of_month.to_date
            result << month_count
            month_count = 0
          end
        end
      end

      result
    end

    def sync
      # daily new users
      history = new_users_count(Time.now-6.days)

      data = {
        "item": [
          {
            "value": history[-1]
          }, history
        ]
      }

      Geckoboard.push "172028-4f7825a3-aea4-4ba1-a8c1-2ef527a49fec", data

      # monthly new users
      history = new_users_count(Time.now-5.months, Time.now, 'month')

      data = {
        "item": [
          {
            "value": history[-1]
          }, history
        ]
      }

      Geckoboard.push "172028-6d52ce9b-2f13-48a9-b400-52c0565dfe08", data
    end
  end
end

class Cohort
  def self.compute(start_time, end_time = Time.now, frequency = 'week')
    start_time = start_time.beginning_of_month.to_datetime
    end_time = end_time.end_of_month.to_datetime

    if frequency == 'week'
      retain_param = [7,14]
    else
      retain_param = [30,60]
    end

    result = []
    month_new_users_count = 0
    month_retained_users_count = 0
    (start_time..end_time).step(1).each do |day|
      # puts "day #{day.strftime('%Y-%m-%d')}"
      new_users = NewUsers.on_date(day)
      # puts "new users #{new_users}"

      month_new_users_count += new_users.count

      # retain_range_orders_users = OrderItem.where(order_status: ['PAID', 'RECEIVED']).where('pay_time >= ? AND pay_time <= ?', day.beginning_of_day+retain_param[0].days, time.end_of_day+retain_param[1].days).pluck('distinct(user_id)')

      retain_range_orders_users = (retain_param[0]...retain_param[1]).map do |offset|
        _k = NewUsers.active_purchase_key(day + offset.days)
        $redis.smembers(_k)
      end.flatten.uniq

      # puts "retain_range_orders_users #{retain_range_orders_users}"

      retained_users = new_users & retain_range_orders_users

      # puts "retained_users #{retained_users}"

      month_retained_users_count += retained_users.count

      if day.to_date == day.end_of_month.to_date
        if month_new_users_count == 0
          result << 0
        else
          result << month_retained_users_count.to_f / month_new_users_count
        end

        month_new_users_count = 0
        month_retained_users_count = 0
      end
    end

    result
  end

  def self.sync
    labels = 6.times.map{ |i| (Time.now - i.months).strftime('%Y-%m') }.reverse

    data = {
      "x_axis": {
        "labels": labels
      },
      "series": [
        {
          "name": "30天留存",
          "data": self.compute(Time.now-5.months, Time.now, "month"),
        },
        {
          "name": "7天留存",
          "data": self.compute(Time.now-5.months, Time.now, "week"),
        }
      ]
    }

    Geckoboard.push "172028-a34ed4d2-4f3a-4ce4-bf99-2f4d105b4259", data
  end
end

