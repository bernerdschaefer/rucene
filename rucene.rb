if RUBY_PLATFORM !~ /java/
  require 'socket'
  require 'jruby-jars'
  require 'rucene/client'
else
  require 'java'
  require 'rubygems'

  require 'json'
  require 'sinatra/base'
  require 'rucene/lucene'

  class Rucene < Sinatra::Base

    @analyzer = Lucene::Analysis::StandardAnalyzer.new(
      Lucene::Util::Version::LUCENE_CURRENT)

    @index = begin
      directory = Lucene::Store::RAMDirectory.new
      # ensure the index is created
      Lucene::Index::IndexWriter.new(
        directory,
        @analyzer,
        true,
        Lucene::Index::IndexWriter::MaxFieldLength.new(25000)
      ).close
      directory
    end

    class << self
      attr_reader :analyzer, :index
    end

    def analyzer
      self.class.analyzer
    end

    def index
      self.class.index
    end

    get '/favicon.ico' do
      404
    end

    get    '/' do
      "nothing to see here"
    end

    post   '/:collection' do     # add document to collection
      data = JSON.parse(request.body.string)

      document = Lucene::Document.new
      document.add Lucene::Field.new(
        "__id__",
        data.delete("id"),
        Lucene::Field::Store::YES,
        Lucene::Field::Index::NOT_ANALYZED
      )
      document.add Lucene::Field.new(
        "__collection__",
        params[:collection],
        Lucene::Field::Store::YES,
        Lucene::Field::Index::ANALYZED
      )

      data.each do |key, value|
        document.add Lucene::Field.new(
          key,
          value,
          Lucene::Field::Store::YES,
          Lucene::Field::Index::ANALYZED
        )
      end

      writer = Lucene::Index::IndexWriter.new(
        index,
        analyzer,
        Lucene::Index::IndexWriter::MaxFieldLength.new(25000)
      )
      writer.addDocument(document)
      writer.close

      content_type 'text/json'
      {'status' => 'ok'}.to_json
    end

    get    '/:collection' do     # query collection
      query = JSON.parse(request.body.string) rescue {}

      if query.empty?
        documents = []

        collection = Lucene::Index::Term.new(
          "__collection__",
          params[:collection])
        reader = Lucene::Index::IndexReader.open(index, true)
        term_docs = reader.termDocs(collection)
        while term_docs.next
          document = reader.document(term_docs.doc)
          fields = document.getFields.map do |field|
            [field.name, field.stringValue]
          end

          documents << Hash[*fields.flatten]
        end
        reader.close

        {'results' => documents}.to_json
      else
        query_parser = Lucene::QueryParser.new(
          Lucene::Util::Version::LUCENE_CURRENT,
          query["field"],
          analyzer)
        query = query_parser.parse(query["term"])

        searcher = Lucene::Search::IndexSearcher.new(index, true)
        results = searcher.search(query, 10).scoreDocs

        documents = []
        ids = results.map do |score_doc|
          document = searcher.doc(score_doc.doc)
          fields = document.getFields.map do |field|
            [field.name, field.stringValue]
          end

          documents << Hash[*fields.flatten]
        end
        searcher.close

        content_type = 'text/json'

        {'results' => documents}.to_json
      end
    end

  end

  Rucene.run! :port => ARGV.last.to_i
end
