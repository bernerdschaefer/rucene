require 'rucene/lucene-3.0.2.jar'

module Lucene
  import "org.apache.lucene"
  import "org.apache.lucene.document"
  import "org.apache.lucene.queryParser"

  module Analysis
    import "org.apache.lucene.analysis.standard"
  end

  module Store
    import "org.apache.lucene.store"
  end

  module Index
    import "org.apache.lucene.index"
  end


  module Search
    import "org.apache.lucene.search"
  end

  module Util
    import "org.apache.lucene.util"
  end
end
