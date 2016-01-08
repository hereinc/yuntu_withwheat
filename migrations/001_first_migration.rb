class FirstMigration < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.integer :product_id
      t.decimal :current_price, precision: 21, scale: 6
      t.string :product_name
      t.datetime :create_time
      t.string :product_code
      t.decimal :pref_price, precision: 21, scale: 6
      t.string :src_sys
      t.datetime :yt_datetime
    end
    add_index :products, :yt_datetime

    create_table :members do |t|
      t.integer :user_id
      t.string :age
      t.string :member_name
      t.datetime :create_time
      t.datetime :record_time
      t.string :regist_shopname
      t.string :__sex__option__
      t.string :sex
      t.string :src_sys
      t.datetime :yt_datetime
    end

    add_index :members, :yt_datetime

    create_table :member_feedbacks do |t|
      t.integer :user_id
      t.datetime :record_time
      t.string :memo
      t.string :feedback_type
      t.datetime :create_time
      t.string :user_name
      t.string :src_sys
      t.datetime :yt_datetime
    end
    add_index :member_feedbacks, :yt_datetime

    create_table :order_items do |t|
      t.datetime :delivery_time
      t.datetime :record_time
      t.integer :meal_count
      t.string :order_status
      t.integer :product_id
      t.integer :user_id
      t.datetime :create_time
      t.string :product_name
      t.decimal :pay_price, precision: 21, scale: 6
      t.string :address
      t.datetime :pay_time
      t.string :order_id
      t.string :member_name
      t.string :__delivery_status__option__
      t.string :delivery_status
      t.string :__order_status__option__
      t.string :src_sys
      t.datetime :yt_datetime
    end
    add_index :order_items, :yt_datetime
  end
end