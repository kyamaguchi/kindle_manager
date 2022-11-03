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

      def title_node
        # Possible to use "div[id^='content-title-']"
        @_title_node ||= @node.css('.digital_entity_title').first
      end

      def asin
        @_asin ||= title_node.attributes['id'].value.remove('content-title-')
      end

      def title
        @_title ||= title_node.text
      end

      def tag
        @_tag ||= @node.css('.information_row.tags').first&.text&.strip
      end

      def author
        @_author ||= @node.css("div[id^='content-author-']").text
      end

      def date
        @_date ||= parse_date(@node.css("div[id^='content-acquired-date-']").text)
      end

      def collection_count
        @_collection_count ||= @node.css('.dropdown_count').first&.text&.strip.to_i
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
        doc.css('#CONTENT_LIST table tbody tr').map{|e| BookRow.new(e, fetched_at: fetched_at) }
      end
    end
  end
end
