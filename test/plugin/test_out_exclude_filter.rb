require 'helper'


class ExcludeFilterOutputTest < Test::Unit::TestCase

  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    key hoge
    value 100
    regexp false
    add_tag_prefix debug
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::OutputTestDriver.new(Fluent::ExcludeFilterOutput).configure(conf)
  end

  def test_configure
    d = create_driver

    assert_equal 'debug', d.instance.config['add_tag_prefix']
    assert_equal 'hoge', d.instance.config['key']
    assert_equal '100', d.instance.config['value']
  end

  def test_format
    d = create_driver
    d.run do
      d.emit("json" => "dayo")
      d.emit("hoge" => "100")
    end
  
    assert_equal [ {"json" => "dayo"} ], d.records 
    
  end
end 
