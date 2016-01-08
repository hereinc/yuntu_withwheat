require File.expand_path('../setup', __FILE__)
require 'uri'

class Importer
  def connection
    ActiveRecord::Base.connection
  end

  def migrate
    dir = File.expand_path('../', __FILE__)
    file = File.join(dir, '/migrations')
    ActiveRecord::Migrator.migrate( file, nil )

    ActiveRecord::Migration.suppress_messages do
      out = File.new(File.join(dir, 'schema.rb'), 'w')
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, out)
      out.close
    end
  end

  MAPPING = {
    products: {
      "CURRENT_PRICE" => :to_f,
      "CREATE_TIME" => ->(x){Time.parse("#{x} +0800")},
      "PREF_PRICE" => :to_f,
    },
    members: {
      "RECORD_TIME" => ->(x){Time.parse("#{x} +0800")},
      "CREATE_TIME" => ->(x){Time.parse("#{x} +0800")},
    },
    member_feedbacks: {
      "RECORD_TIME" => ->(x){Time.parse("#{x} +0800")},
      "CREATE_TIME" => ->(x){Time.parse("#{x} +0800")},
    },
    order_items: {
      "PAY_PRICE" => :to_f,
      "PAY_TIME" => ->(x){Time.parse("#{x} +0800")},
      "RECORD_TIME" => ->(x){Time.parse("#{x} +0800")},
      "CREATE_TIME" => ->(x){Time.parse("#{x} +0800")},
      "DELIVERY_TIME" => ->(x){Time.parse("#{x} +0800")},
    },
  }

  def clean_model_attributes model_type, attrs
    mapping = MAPPING[model_type.to_sym]

    new_attrs = {}
    attrs.each do |k, v|
      new_attrs[k.downcase] = if mapping[k]
        case mapping[k]
        when Symbol
          v.send(mapping[k])
        when Proc
          mapping[k].call(v)
        else
          v
        end
      else
        v
      end
    end

    new_attrs
  end

  URL_PARTIAL_MAP = {
    'order_items' => 'Orders'
  }

  def import model_name, start_time, end_time = nil
    klass = Importer.const_get model_name.classify

    url_partual = URL_PARTIAL_MAP[model_name] || klass.name.to_s

    # start_time = Time.zone.local(2016, 1, 1, 0, 0, 0).beginning_of_day
    # end_time = Time.now.end_of_day
    # end_time = Time.zone.local(2016, 1, 6, 0, 0, 0).end_of_day

    url_params = {
      start_timestamp: start_time.strftime('%Y-%m-%d %H:%M:%S'),
      end_timestamp: end_time.strftime('%Y-%m-%d %H:%M:%S'),
      sign: '123456',
      timestamp: Time.now.strftime('%Y-%m-%d %H:%M:%S')
    }

    url_params.each do |k, v|
      url_params[k] = URI.encode(v)
    end

    base_url = "http://it.zaofans.com:8070/yun_wheat/datacube/get#{url_partual}"
    url = "#{base_url}?#{url_params.map{|k,v| "#{k}=#{v}"}.join('&')}"
    puts url
    result = RestClient.get url, {}

    json = JSON(result)

    if !json['success']
      puts "ERROR!!!!! Time.zone.now"
      puts json.inspect
    end

    count = json["data"].length
    puts "GET #{model_name} done! count is #{count}"

    if count == 0
      puts "data blank"
      return
    end

    klass.transaction do
      print "delete old data..."
      klass.where(yt_datetime: start_time..end_time).destroy_all
      puts "done"
      puts "start save"

      i = 0
      json["data"].each do |p|
        i += 1
        puts "process #{i}/#{count}" if i % 100 == 0
        klass.create clean_model_attributes(model_name.to_sym, p).merge(
          yt_datetime: start_time
        )
      end
      puts "done"
    end
  end

  def import_all start_time, end_time = nil
    start_time, end_time = format_times(start_time, end_time)
    import 'products', start_time, end_time
    import 'members', start_time, end_time
    import 'member_feedbacks', start_time, end_time
    import 'order_items', start_time, end_time
  end

  def import_single model_name, start_time, end_time = nil
    start_time, end_time = format_times(start_time, end_time)
    import model_name, start_time, end_time
  end

  def format_times start_time, end_time = nil
    if !(start_time =~ /^\d{4}-\d{2}-\d{2}$/) ||
      (end_time && !(end_time =~ /^\d{4}-\d{2}-\d{2}$/))
      abort 'need xxxx-xx-xx format time data'
      return
    end

    start_time = Time.parse(start_time)
    if end_time.nil?
      end_time = start_time
    else
      end_time =  Time.parse(end_time)
    end

    start_time = start_time.beginning_of_day
    end_time = end_time.end_of_day

    if end_time < start_time
      abort "end_time < start_time error"
      return
    end

    return [start_time, end_time]
  end
end