require 'helper'


class ExcludeFilterOutputTest < Test::Unit::TestCase
  # TMP_DIR = File.dirname(__FILE__) + "/../tmp"

  def setup
    Fluent::Test.setup
    # FileUtils.rm_rf(TMP_DIR)
    # FileUtils.mkdir_p(TMP_DIR)
  end

  CONFIG = %[
  ]
  # CONFIG = %[
  #   path #{TMP_DIR}/out_file_test
  #   compress gz
  #   utc
  # ]

  def create_driver(conf = CONFIG)
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::ExcludeFilterOutput).configure(conf)
  end

  def test_configure
    #### set configurations
    # d = create_driver %[
    #   path test_path
    #   compress gz
    # ]
    #### check configurations
    # assert_equal 'test_path', d.instance.path
    # assert_equal :gz, d.instance.compress
  end

end 
