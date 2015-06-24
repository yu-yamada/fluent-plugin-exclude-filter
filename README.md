# fluent-plugin-exclude-filter, a plugin for [Fluentd](http://fluentd.org) 

exclude some records.

## Installation


    gem install fluent-plugin-exclude-filter
## Configuration

### Simple exclude
    <match test.**>
      type exclude_filter
      key hoge
      value 100
      regexp false # default false, string comparison
      add_tag_prefix debug.
    </match>  

  `remove_tag_prefix`, `remove_tag_suffix` and `add_tag_suffix` options are also supported

#### Assuming following inputs are coming:
    test.aa: {"json":"dayo"}
    test.aa: {"hoge":"100"}
#### then output becomes as belows
    debug.test.aa: {"json":"dayo"} 

### Use YmlFile exclude
    <match test.**>
      type exclude_filter
      file_path path/to/test.yml 
      regexp true # default false
      add_tag_prefix debug.
    </match>  

#### test.yml as blows

```
hoge: 100
moge:
  - ^aaa
  - bbb
```

#### Assuming following inputs are coming:
    test.aa: {"json":"dayo"}
    test.aa: {"hoge":"100"}
    test.aa: {"hoge":"200"}
    test.aa: {"moge":"aaa bbb"}
    test.aa: {"moge":"aaa ccc"}
    test.aa: {"moge":"ccc bbb"}
    test.aa: {"moge":"ccc ddd"}
#### then output becomes as belows
    debug.test.aa: {"json":"dayo"}
    debug.test.aa: {"hoge":"200"}
    debug.test.aa: {"moge":"ccc ddd"}

### Forward excluded
    <match test.**>
      type exclude_filter
      file_path path/to/test.yml
      add_tag_prefix debug.
      <excluded>
        add_tag_prefix excl.
      </excluded>
    </match>

  with the same test.yml file as above

#### Assuming following inputs are coming:
    test.aa: {"json":"dayo"}
    test.aa: {"hoge":"100"}
    test.aa: {"hoge":"200"}
    test.aa: {"moge":"aaa bbb"}
    test.aa: {"moge":"aaa ccc"}
    test.aa: {"moge":"ccc bbb"}
    test.aa: {"moge":"ccc ddd"}
#### then output becomes as belows
    debug.test.aa: {"json":"dayo"} 
    excl.test.aa: {"hoge":"100"}
    debug.test.aa: {"hoge":"200"}
    excl.test.aa: {"moge":"aaa bbb"}
    excl.test.aa: {"moge":"aaa ccc"}
    excl.test.aa: {"moge":"ccc bbb"}
    debug.test.aa: {"moge":"ccc ddd"}

  routing non matching messages with tag `excl.` prepended instead of `debug.`

## Copyright
    Copyright (c) 2014 yu-yamada
