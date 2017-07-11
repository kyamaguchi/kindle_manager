module KindleManager
  class BooksParser < BaseParser
    class BookRow

      include KindleManager::Parsers::Common

      def initialize(node, options = {})
        @node = node
        @fetched_at = options[:fetched_at]
      end

      def inspect
        "#<#{self.class.name}:#{self.object_id} #{self.to_hash}>"
      end

      def asin
        @_asin ||= @node['name'].gsub(/\AcontentTabList_/, '')
      end

      def title
        @_title ||= @node.css("div[id^='title']").text
      end

      def tag
        @_tag ||= @node.css("div[id^='listViewTitleTag']").css('.myx-text-bold').first.text.strip
      end

      def author
        @_author ||= @node.css("div[id^='author']").text
      end

      def date
        @_date ||= parse_date(@node.css("div[id^='date']").text)
      end

      def collection_count
        @_collection_count ||= @node.css(".collectionsCount .myx-collection-count").first.text.strip.to_i
      end

      def to_hash
        hash = {}
        %w[asin title tag author date collection_count].each do |f|
          hash[f] = send(f)
        end
        hash
      end
    end

    def parse
      @_parsed ||= begin
        doc.css("div[id^='contentTabList_']").map{|e| BookRow.new(e, fetched_at: fetched_at) }
      end
    end
  end
end
