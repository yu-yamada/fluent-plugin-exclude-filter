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
  end

  def configure(conf)
    super

    @key = @key.to_s
    @value = @value.to_s 

   @excludes_yml = nil
   if @file_path
     @excludes_yml = YAML.load_file(@file_path)
   end 
  end

  def emit(tag, es, chain)

    es.each do |time,record|
      if @key && @value
        next if match(@key, @value, record) 
      end
      if @excludes_yml
        next if yml_match(record)
      end 

      emit_tag = tag.dup
      filter_record(emit_tag, time, record)
      Fluent::Engine.emit(emit_tag, time, record)
    end

    chain.next
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
end
