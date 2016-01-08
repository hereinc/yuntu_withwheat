ENV['RUBY_ENV'] = 'test'
require 'minitest/autorun'

require File.expand_path('../setup', __FILE__)
require File.expand_path('../importer', __FILE__)
require File.expand_path('../cohort', __FILE__)

class CartItemTest < Minitest::Test
  YEAR = 2008

  def setup
    $redis.keys.each { |x| $redis.del x }
    create_order_item 8,  1,  [1]
    create_order_item 8,  2,  [2, 3, 1]
    create_order_item 8,  4,  [5]
    create_order_item 8,  9,  [1, 5]
    create_order_item 8,  20, [2]
    create_order_item 9,  8,  [3, 6]
    create_order_item 10, 18, [6]
    create_order_item 10, 20, [3]
    NewUsers.compute(new_time(YEAR, 8, 1), new_time(YEAR, 10, 20))
  end

  def test_new_user_count
    assert_equal [0, 1, 2], NewUsers.new_users_count(new_time(YEAR, 7, 31), new_time(YEAR, 8, 2))
    assert_equal [2, 0, 1, 0, 0, 0, 0, 0, 0], NewUsers.new_users_count(new_time(YEAR, 8, 2), new_time(YEAR, 8, 10))
    assert_equal [0], NewUsers.new_users_count(new_time(YEAR, 7, 30), new_time(YEAR, 7, 30), 'month')
    assert_equal [0, 4, 1, 0, 0], NewUsers.new_users_count(new_time(YEAR, 7, 31), new_time(YEAR, 11, 2), 'month')

    assert_equal [0], Cohort.compute(new_time(YEAR, 7, 30), new_time(YEAR, 7, 30), 'week')
    assert_equal [0, 0.25, 0, 0, 0], Cohort.compute(new_time(YEAR, 7, 30), new_time(YEAR, 11, 20), 'week')
    assert_equal [0, 0.25, 1.0, 0, 0], Cohort.compute(new_time(YEAR, 7, 30), new_time(YEAR, 11, 20), 'month')
  end

  private

  def new_time *p
    Time.zone.local *p
  end

  def create_order_item month, day, user_ids
    user_ids.each do |user_id|
      OrderItem.create(
        order_status: 'RECEIVED',
        user_id: user_id,
        pay_time: new_time(YEAR, month, day, 0, 0, 0)
      )
    end
  end
end