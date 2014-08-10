require 'yaml'
class Fluent::ExcludeFilterOutput < Fluent::Output
  Fluent::Plugin.register_output('exclude_filter', self)

  config_param :key, :string, :default => nil
  config_param :value, :string, :default => nil
  config_param :file_path, :string, :default => nil
  config_param :regexp, :bool, :default => false
  config_param :add_tag_prefix, :string, :default => 'exclude'

  def initialize
    super
  end

  def configure(conf)
    super

    @key = @key.to_s
    @value = @value.to_s 
    @tag_prefix = "#{@add_tag_prefix}."

    @tag_proc =
      if @tag_prefix
        Proc.new {|tag| "#{@tag_prefix}#{tag}" }
      else
        Proc.new {|tag| tag }
      end

   @excludes_yml = nil
   if @file_path
     @excludes_yml = YAML.load_file(@file_path)
   end 
  end

  def emit(tag, es, chain)
    emit_tag = @tag_proc.call(tag)

    es.each do |time,record|
      if @key && @value
        next if match(@key, @value, record) 
      end
      if @excludes_yml
        next if yml_match(record)
      end 

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
