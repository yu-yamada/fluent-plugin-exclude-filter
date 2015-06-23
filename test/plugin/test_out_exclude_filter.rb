require 'helper'


class ExcludeFilterOutputTest < Test::Unit::TestCase

  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    key hoge
    value 100
    regexp false
    add_tag_prefix debug.
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::OutputTestDriver.new(Fluent::ExcludeFilterOutput).configure(conf)
  end

  def test_configure
    d = create_driver

    assert_equal 'debug.', d.instance.add_tag_prefix
    assert_equal 'hoge', d.instance.config['key']
    assert_equal '100', d.instance.config['value']
  end

  def test_simple
    d = create_driver
    d.run do
      d.emit("json" => "dayo")
      d.emit("hoge" => "100")
    end
  
    assert_equal [ {"json" => "dayo"} ], d.records 
    assert_equal  "debug.#{d.tag}", d.emits[0][0]
    
  end
  def test_yml
    yml_path = File.dirname(__FILE__) + "/../conf/test.yml"

    d = create_driver %[
          file_path #{yml_path}
          regexp true
          add_tag_prefix debug
        ]

    d.run do
      d.emit("json" => "dayo")
      d.emit("hoge" => "100")
      d.emit("hoge" => "200")
      d.emit("moge" => "aaa bbb")
      d.emit("moge" => "aaa ccc")
      d.emit("moge" => "ccc bbb")
      d.emit("moge" => "ccc ddd")
    end
    assert_equal [ {"json"=>"dayo"}, {"hoge"=>"200"}, {"moge"=>"ccc ddd"} ], d.records 
  end
end 
