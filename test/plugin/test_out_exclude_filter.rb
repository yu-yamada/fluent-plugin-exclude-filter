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

  EXCLUDE_CONFIG = %[
    <excluded>
      add_tag_prefix excl.
    </excluded>
  ]

  CONFIG_WITH_EXCLUDE = CONFIG + EXCLUDE_CONFIG

  def create_driver(conf = CONFIG)
    Fluent::Test::OutputTestDriver.new(Fluent::ExcludeFilterOutput).configure(conf)
  end

  def test_configure
    d = create_driver

    assert_equal 'debug.', d.instance.add_tag_prefix
    assert_equal 'hoge', d.instance.config['key']
    assert_equal '100', d.instance.config['value']
    assert d.instance.excluded.nil?

    d = create_driver(CONFIG_WITH_EXCLUDE)

    assert_equal 'debug.', d.instance.add_tag_prefix
    assert_equal 'hoge', d.instance.config['key']
    assert_equal '100', d.instance.config['value']
    assert_equal Fluent::ExcludeFilterOutput::TagNameMixer, d.instance.excluded.class
    assert_equal 'excl.', d.instance.excluded.add_tag_prefix
  end

  def test_configure_raise
    assert_raise(Fluent::ConfigError) do
      create_driver(CONFIG + EXCLUDE_CONFIG * 2)
    end
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

  def test_simple_with_excluded
    d = create_driver(CONFIG_WITH_EXCLUDE)
    emits = [
      {"json" => "dayo"},
      {"hoge" => "100"}  ]
    d.run do
      emits.each { |e|
        d.emit(e)
      }
    end

    assert_equal emits, d.records
    assert_equal [ "debug.#{d.tag}", "excl.#{d.tag}" ] , d.emits.map {|tag, time, record| tag}
  end

  def test_yml
    yml_path = File.dirname(__FILE__) + "/../conf/test.yml"

    d = create_driver %[
          file_path #{yml_path}
          regexp true
          add_tag_prefix debug.
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
    d.emits.each { |tag, time, record|
      assert_equal "debug.#{d.tag}", tag
    }
  end

  def test_yml_with_excluded
    yml_path = File.dirname(__FILE__) + "/../conf/test.yml"

    d = create_driver (%[
          file_path #{yml_path}
          regexp true
          add_tag_prefix debug.
        ] + EXCLUDE_CONFIG)

    emits = [
      {"json" => "dayo"},
      {"hoge" => "100"},
      {"hoge" => "200"},
      {"moge" => "aaa bbb"},
      {"moge" => "aaa ccc"},
      {"moge" => "ccc bbb"},
      {"moge" => "ccc ddd"}  ]
    d.run do
      emits.each { |e|
        d.emit(e)
      }
    end
    assert_equal emits, d.records 
    assert_equal [
      "debug.#{d.tag}",
      "excl.#{d.tag}",
      "debug.#{d.tag}",
      "excl.#{d.tag}",
      "excl.#{d.tag}",
      "excl.#{d.tag}",
      "debug.#{d.tag}" ] , d.emits.map {|tag, time, record| tag}
  end
end 
