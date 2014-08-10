# fluent-plugin-exclude-filter, a plugin for [Fluentd](http://fluentd.org) 

exclude some records.

## Installation


    gem install fluent-plugin-exclude-filter
## Configuration

### Simple exclude
    <match test.**>
      type exclude-filter
      key hoge
      value 100
      regexp false # default false, string comparison
      add_tag_prefix debug
    </match>  

#### Assuming following inputs are coming:
    test.aa: {"json":"dayo"}
    test.aa: {"hoge":"100"}
#### then output bocomes as belows
    debug.test.aa: {"json":"dayo"} 

### Use YmlFile exclude
    <match test.**>
      type exclude-filter
      file_path path/to/test.yml 
      regexp true # default false
      add_tag_prefix debug
    </match>  

#### test.yml as blows

  <p>
  hoge: 100
  moge:
   - ^aaa
   - bbb
  </p>

#### Assuming following inputs are coming:
    test.aa: {"json":"dayo"}
    test.aa: {"hoge":"100"}
    test.aa: {"hoge":"200"}
    test.aa: {"moge":"aaa bbb"}
    test.aa: {"moge":"aaa ccc"}
    test.aa: {"moge":"ccc ddd"}
#### then output bocomes as belows
    debug.test.aa: {"json":"dayo"} 
    debug.test.aa: {"hoge":"200"}
    debug.test.aa: {"moge":"ccc ddd"}


## Copyright
    Copyright (c) 2014 yu-yamada
