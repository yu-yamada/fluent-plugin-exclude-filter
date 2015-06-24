require 'yaml'
class Fluent::ExcludeFilterOutput < Fluent::Output
  include Fluent::HandleTagNameMixin

  Fluent::Plugin.register_output('exclude_filter', self)

  config_param :key, :string, :default => nil
  config_param :value, :string, :default => nil
  config_param :file_path, :string, :default => nil
  config_param :regexp, :bool, :default => false

  def initialize
    super
    @excluded = nil
  end

  attr_reader :excluded

  def configure(conf)
    super

   @excludes_yml = nil
   if @file_path
     @excludes_yml = YAML.load_file(@file_path)
   end 

    store_excluded_conf = conf.elements.select {|element|
      element.name == 'excluded'
    }
    case store_excluded_conf.length
    when 0
      @excluded = nil
    when 1
      e = store_excluded_conf[0]
      @excluded = TagNameMixer.new()
      @excluded.configure(e)
    else
      raise Fluent::ConfigError, "exclude_filter: <excluded> directive should be defined only once."
    end
  end

  def emit(tag, es, chain)

    es.each do |time,record|
      if any_match(record)
        if @excluded
          emit_tag = tag.dup
          @excluded.filter_record(emit_tag, time, record)
          Fluent::Engine.emit(emit_tag, time, record)
        end
        next
      end

      emit_tag = tag.dup
      filter_record(emit_tag, time, record)
      Fluent::Engine.emit(emit_tag, time, record)
    end

    chain.next
  end

  def any_match(record)
    if @key && @value
      return true if match(@key, @value, record) 
    end
    if @excludes_yml
      return true if yml_match(record)
    end 
    return false
  end

  def yml_match(record)
    @excludes_yml.each{|k,v| 
      if v.kind_of?(Array)
        v.each{|va|
          if match(k, va, record)
            return true
          end
        }
      else
        if match(k, v, record)
          return true
        end
      end
    }
    return false
  end
  def match(k, v, record)
    if @regexp
      return Regexp.compile(v.to_s).match(record[k])
    else
      return record[k] == v.to_s
    end
  end 

  class TagNameMixer < Object
    include Fluent::Configurable
    include Fluent::HandleTagNameMixin
  end
end
