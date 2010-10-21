Rucene
======

Rucene demonstrates how to build a simple REST API for Lucene using Ruby and
JRuby with `jruby-jars`.

To get started, just `bundle install` and then run `ruby speakers.rb`. Then go
to `http://localhost:9092` to see the demo app. You'll notice in the logs that
it's communicating with a sinatra app running on 9091 -- that's the JRuby
application serving a Lucene index.
